# CI/CD Application Deploy (post-provision layer)

Generates the GitHub Actions workflow that runs a solution's **application-deployment steps**
after the Bicep infrastructure is provisioned — building/pushing container images and running
the repo's post-provision scripts. It is the companion to `fde-cicd-bicep-workflows` (the infra
skill): that skill deploys the infrastructure; this one deploys the application on top of it.

## Use when
The user wants to automate the steps that follow `azd up` / an infra deployment — building app
images into the deployment's container registry, installing post-provision dependencies, and
running the solution build scripts — as a CI/CD job, ideally chained into the same pipeline as
the infra deploy so one run provisions **and** configures the solution.

## What this skill ships
- **`templates/`** — `_app-deploy.yml` (reusable `workflow_call` engine that runs the app-deploy
  steps) and `app-deploy.yml` (an example per-solution **manifest**).
- **`references/`** — `app-deploy-conventions.md` (manifest schema, the outputs→env bridge, and
  step-classification rules).
- **`scripts/`** — `inspect-app-deploy.sh` (read-only discovery of the repo's build scripts,
  post-provision entrypoint, requirements, and scenarios).

## Hard constraints
- **Ask before any mutation.** Confirm with the user (via an interactive input tool when
  available) before writing repo files, changing GitHub environments/variables, or triggering a
  deployment. Read-only discovery needs no approval.
- **No source changes.** Never edit the repo's Bicep files, application code, or post-provision
  **scripts**. The pipeline adapts to the existing scripts; it does not rewrite them. Only
  workflow/manifest files under `.github/` are authored, plus per-environment `.bicepparam`
  **values** when CI-identity parameters must change (values only, never Bicep code).
- **Outputs→env bridge (no script edits).** The post-provision scripts read configuration from
  `os.environ`. The pipeline reproduces what `azd` writes to `.azure/<env>/.env` by reading the
  infra deployment's **outputs** (`az deployment group show`) and exporting them to
  `$GITHUB_ENV`. The Bicep output names already match the variables the scripts expect — so no
  script changes are required. See `references/app-deploy-conventions.md`.
- **Classify every step; never blindly transcribe the guide.** Read the repo's deployment guide
  and scripts and sort each step into one of three buckets, then **confirm the split with the
  user** before generating anything:
  - **include** — runs in the pipeline (build images, install deps, `00_build_solution.py`).
  - **developer-only** — excluded (interactive local testing such as `06_test_agent.py`,
    `az login`/device-code, venv/activation, IDE onboarding, any `input()` prompt).
  - **manual-post-step** — cannot run unattended; emitted only as a reminder in the run summary
    (for example OBO/on-behalf-of auth configured in the portal, which can take ~10 min).
- **Non-interactive execution.** Post-provision entrypoints may contain `input()` prompts (e.g.
  an unconditional "Press Enter to start"). Drive them non-interactively **without editing the
  script** — feed stdin (`echo "" | python ...`) and select a scenario via flags
  (`--scenario <name>` or `--industry/--usecase`) so no interactive branch is reached.
- **Depends on the infra deploy.** This workflow runs after a successful infra deployment and
  needs the **deployment name** and target **resource group** to read outputs. When chained
  after `fde-cicd-bicep-workflows`, consume the deployment name that `_infra.yml` exposes as a
  job output; otherwise resolve the most recent successful deployment in the resource group.
- **Use the bundled scripts.** Run `scripts/*.sh` in place by absolute path; never copy them into
  the target repo or replace them with inline Python/ad-hoc one-offs. Extend a script if a
  capability is missing.
- **Rely on active sessions.** Use the user's existing `az login` / `gh` sessions; never ask for
  credentials.
- **Temp files under `.agent/tmp/`, always cleaned up.** Write all scratch/intermediate files
  (e.g. `app-facts.json`) only under `.agent/tmp/` — never in the repo root, `.github/`, `infra/`,
  or the skill folder — and remove them before finishing, even on failure.
- **Variables only, never secrets.** Reuse the same OIDC identity Variables as the infra skill
  (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`). Never read/set GitHub secrets
  and never print variable *values*.
- **Best practices** (shared with the infra skill): pin actions to a full commit SHA (with a
  `# vX.Y.Z` comment); prefer first-party `actions/*` and official `azure/login`; least-privilege
  `permissions`; OIDC via `azure/login` (`id-token: write`, no client secret); reusable workflows.

## Process
1. **Validate tools.** Confirm `jq` is available and the user has active `az`/`gh` sessions
   (reuse the infra skill's `check-prereqs.sh` when present).
2. **Inspect the repo.** Run `scripts/inspect-app-deploy.sh > .agent/tmp/app-facts.json`. It
   reports: the deployment guide path; image-build scripts (`infra/scripts/build/*`) and whether
   they accept `--resource-group`; the post-provision entrypoint (`00_build_solution.py`) and its
   flags; the requirements file; available scenarios; and any detected `input()` prompts /
   dev-only scripts.
3. **Classify the steps.** From `app-facts.json` + the deployment guide, build the
   include / developer-only / manual-post-step lists per the rules above. Note which scenario the
   run should use (ask the user; default to the guide's example) and any manual reminders (e.g.
   OBO auth, only relevant when `useUserAccessToken=true`).
4. **Confirm the split with the user.** Present the three lists, the chosen scenario, the target
   environment(s), and how the pipeline chains onto the infra deploy. **Get explicit approval
   before writing files.**
5. **Resolve the outputs→env bridge.** Confirm the infra deployment name source (Skill A job
   output, or "latest successful deployment in the resource group") and list any values the
   scripts need that are **inputs rather than outputs** (e.g. `FABRIC_WORKSPACE_ID` when reusing a
   workspace) — those are passed via the manifest's `extra_env`.
6. **Render files** into `.github/`:
   - `workflows/_app-deploy.yml` — the reusable engine (copy from `templates/`; adjust only the
     runtime and step set to match the manifest).
   - `app-deploy.yml` — the per-solution manifest capturing the confirmed classification: build
     commands, runtime, post-provision command + scenario, `env_from_outputs` toggle,
     `extra_env`, `smoke_test` (disabled by default), and `manual_post_steps`.
7. **Chain into the infra pipeline (optional but preferred).** Add an app-deploy job to the infra
   skill's `bicep-deploy.yml` that `needs:` the gated `apply-<env>` job and calls `_app-deploy.yml`,
   passing `deployment_name: ${{ needs.apply-<env>.outputs.deployment_name }}` (exposed by the
   infra skill's `_infra.yml`). Use `templates/bicep-deploy.app-deploy-job.yml` as the snippet,
   one per stage that should deploy the app — so one push provisions **and** configures the
   solution behind a single approval. Confirm before modifying `bicep-deploy.yml`.
8. **Set CI-identity parameters (values only).** If the post-provision path assumes an interactive
   *user* token, set the CI-appropriate values in the per-env `.bicepparam` — e.g.
   `useUserAccessToken = false` and the service-principal `deployingUserPrincipalType`/id — never
   by editing Bicep code. Confirm before changing parameter files.
9. **Validate.** Lint/parse the rendered workflow (reuse the infra skill's `validate-workflows.sh`
   when present) and report the result.
10. **Clean up** all files created under `.agent/tmp/` (remove the directory if empty), even if an
    earlier step failed.

## Output
Report, in order:
1. **Detected app-deploy steps** — guide path, build scripts, post-provision entrypoint, runtime,
   requirements, scenarios.
2. **Classification** — the include / developer-only / manual-post-step lists, confirmed with the
   user, and the chosen scenario.
3. **Generated files** — `_app-deploy.yml`, the `app-deploy.yml` manifest, and any change to
   `bicep-deploy.yml`.
4. **Setup required** — reused OIDC Variables, any `extra_env` inputs, CI-identity `.bicepparam`
   values, and the manual post-steps the user must still perform (e.g. OBO auth).
5. **Validation** — the workflow lint/parse result.
6. **Cleanup** — confirm `.agent/tmp/` files were removed.

## Known environmental risks (surface to the user; not code changes)
- **Fabric API access for a service principal.** Post-provision steps request a Microsoft Fabric
  API token; a service principal can obtain one only if the Fabric tenant admin has enabled
  service-principal access to Fabric APIs. Flag this as a tenant setting the user may need.
- **Subscription-scoped identity.** If the infra skill's `CREATE_RESOURCE_GROUP` toggle is on, the
  shared identity already needs subscription-scoped Contributor; app-deploy reuses that identity.
