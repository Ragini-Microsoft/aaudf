# Bicep → Terraform converter (1:1 infrastructure port)

Produces a **faithful 1:1 Terraform port** of an existing Bicep infrastructure into a new
`infra_tf/` directory that **coexists** with the original `infra/` (Bicep). The port deploys the
same resources and — critically — emits the **same output contract** the solution's post-provision
scripts consume, so the app-deploy layer works unchanged regardless of which stack provisioned.

## Use when
The user wants to convert, port, or migrate existing Bicep infrastructure to Terraform, or to add
a Terraform flavor alongside Bicep. This skill authors HCL; it does **not** deploy it and does not
generate CI/CD (that is `fde-cicd-terraform-workflows`).

## What this skill ships
- **`references/`** — `bicep-to-terraform-mapping.md` (resource/param/output mapping rules) and
  `naming-conventions.md` (the `infra_tf/` layout, `<env>.tfvars`, provider/backend conventions).
- **`scripts/`** — `inspect-bicep.sh` (read-only discovery of the Bicep entrypoint, its parameters,
  outputs, referenced modules, and resource types → `bicep-facts.json`).
- **`templates/`** — skeleton `providers.tf` / `variables.tf` / `outputs.tf` and a module skeleton,
  to seed the generated `infra_tf/` root and modules.

## Hard constraints
- **Faithful 1:1 port.** Reproduce the source's resources, properties, and dependencies — do not
  redesign, "improve", add, or drop resources. Deviate only where a Terraform provider genuinely
  requires it (document each such deviation).
- **Preserve the output contract.** Every output the source `main.bicep` emits **must** exist in
  `infra_tf/outputs.tf` with an equivalent value. The post-provision scripts read these as
  `UPPER_SNAKE` environment variables; Terraform output names are conventional lowercase and the
  app-deploy bridge upcases them, so `resource_group_name` → `RESOURCE_GROUP_NAME`. Names must
  round-trip exactly (ascii-uppercased TF name == the Bicep output name). When a Bicep output name
  is already `UPPER_SNAKE`, emit the TF output as its lowercase form. **Never rename or drop an
  output.**
- **Never touch the source.** Do not edit the repo's Bicep files, application code, or
  post-provision scripts. Only author files under `infra_tf/`.
- **Coexist, never replace.** `infra/` (Bicep) stays intact. Everything you write goes under a new
  `infra_tf/` sibling directory.
- **Ask before any mutation.** Confirm with the user (via an interactive input tool when available)
  before writing any file under `infra_tf/`. Read-only discovery needs no approval.
- **Use the bundled script.** Run `scripts/inspect-bicep.sh` in place by absolute path; never copy
  it into the target repo. Extend it if a capability is missing.
- **Rely on active sessions.** Use the user's existing `az` session for any read-only lookup; never
  ask for credentials. Do not deploy anything.
- **Temp files under `.agent/tmp/`, always cleaned up.** Write scratch (e.g. `bicep-facts.json`)
  only under `.agent/tmp/` and remove it before finishing, even on failure.
- **No state, no backend deploy.** This skill authors the `backend "azurerm"` *block shape* only;
  it never creates the state storage account (that is a documented prerequisite handled by the
  CI/CD skill). Do not run `terraform init`/`plan`/`apply`.

## Process
1. **Pick the source entrypoint & flavor.** Default to `infra/main.bicep`. If it is a router with a
   `deploymentFlavor`-style switch (e.g. `bicep` / `avm` / `avm-waf`), **ask the user which single
   flavor to port first** and follow only that branch's module tree. Port one flavor per run.
2. **Inspect.** Run `scripts/inspect-bicep.sh <entrypoint> > .agent/tmp/bicep-facts.json`. It reports
   the target scope, parameters (with defaults/allowed/types), outputs (names + expressions),
   referenced modules for the chosen flavor, and the distinct Azure resource types used.
3. **Confirm scope with the user.** Present the resource inventory, the parameter list, and the full
   output list that must be preserved. Confirm the `infra_tf/` layout (mirror the source's module
   structure: a root module plus one child module per Bicep module) and the per-env `.tfvars`
   mapping (`infra/params/<env>.bicepparam` → `infra_tf/<env>.tfvars`). **Get explicit approval
   before writing files.**
4. **Author `infra_tf/` — root.** Seed from `templates/`:
   - `providers.tf` — `terraform{}` `required_version` + `required_providers` (`azurerm`, and
     `azapi` when the source uses preview resource types via `Microsoft.*@<api-version>`, plus
     `random` if unique-suffix logic is present), the `provider "azurerm" { features {} }` block,
     and the **partial** `backend "azurerm" {}` block (init values supplied later by CI, never
     committed here).
   - `variables.tf` — one `variable` per Bicep `param`, carrying over type, `default`, and
     `validation` blocks from `@allowed`/`@minValue`/`@minLength` decorators.
   - `main.tf` — resources/`module` calls mirroring the source `main.bicep`, using the mapping
     rules in `references/bicep-to-terraform-mapping.md`. Preserve dependency order (implicit refs
     first; add `depends_on` only where Bicep had an explicit dependency).
   - `outputs.tf` — every source output, value-equivalent (see the output-contract constraint).
5. **Author `infra_tf/modules/<name>/`** — one child module per source Bicep module, each with its
   own `main.tf` / `variables.tf` / `outputs.tf`, wired from the root exactly as the Bicep root
   wired its modules. **Any module that uses `azapi_*` (or `random_*`) MUST also ship a
   `versions.tf` declaring that provider source** (`azapi = { source = "Azure/azapi" }`) — the
   root's `required_providers` does not propagate to child modules, and `terraform init` fails
   otherwise (`hashicorp/azapi` does not exist). See `references/bicep-to-terraform-mapping.md`.
6. **Author per-env `.tfvars`.** For every discovered stage, translate `params/<env>.bicepparam`
   values into `infra_tf/<env>.tfvars` (values only). Keep CI-identity values (e.g.
   `deploying_user_principal_type = "ServicePrincipal"`) faithful to the source.
7. **Flag provider-forced deviations.** List any place where Terraform required a different shape
   than Bicep (e.g. `azapi_resource` for a preview type, `ignore_changes` for a known drift quirk,
   a `random_string` suffix where Bicep used `uniqueString()`), with a one-line reason each.
8. **Format & static-check (no backend).** If `terraform` is available, run
   `terraform fmt -recursive infra_tf` and `terraform -chdir=infra_tf validate` after
   `terraform -chdir=infra_tf init -backend=false`. Report results. If `terraform` is unavailable,
   say so and skip — do not fail the port.
9. **Clean up** all files created under `.agent/tmp/` (remove the directory if empty), even if an
   earlier step failed.

## Output
Report, in order:
1. **Source** — entrypoint, chosen flavor, target scope, stage(s) discovered.
2. **Inventory** — resource types ported, module count, parameter count.
3. **Output contract** — the full list of preserved outputs (source name → TF output name),
   confirming none were dropped or renamed.
4. **Generated files** — the `infra_tf/` tree written and each file's purpose.
5. **Deviations** — every provider-forced difference from the source, with its reason.
6. **Validation** — `fmt`/`validate` result, or a note that `terraform` was unavailable.
7. **Cleanup** — confirm `.agent/tmp/` files were removed.
8. **Next step** — point to `fde-cicd-terraform-workflows` to generate the pipeline, and note the
   state-backend bootstrap is a prerequisite there.
