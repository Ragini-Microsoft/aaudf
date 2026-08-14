# Post-deploy conventions

How the post-deploy layer runs a solution's post-provision steps in CI **without editing any
Bicep, application, or post-provision script** — only workflow files under `.github/workflows/`.

## The outputs → env bridge (why no script changes are needed)

The repo's post-provision scripts (`infra/scripts/post-provision/*`) read every Azure value from
`os.environ`. Locally, `azd up` writes those values to `.azure/<env>/.env`, and `load_env.py`
loads that file with `python-dotenv` — which **does not override** variables already present in
`os.environ`. So if the pipeline populates the environment first, the scripts consume it exactly
as if `azd` had written the `.env`. No script edit is required.

The pipeline reproduces that environment by reading the **infra deployment's outputs** and
exporting them to `$GITHUB_ENV`:

```bash
az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --query properties.outputs -o json \
| jq -r '
    to_entries[]
    | select((.value.value | type) as $t | $t == "string" or $t == "number" or $t == "boolean")
    | "\(.key | ascii_upcase)=\(.value.value | tostring)"
  ' >> "$GITHUB_ENV"
```

Key points:
- **Names already match.** The Bicep outputs are declared in `UPPER_SNAKE_CASE`
  (`SOLUTION_NAME`, `AZURE_OPENAI_ENDPOINT`, `AZURE_AI_AGENT_ENDPOINT`, `FABRIC_WORKSPACE_ID`, …)
  — the same names `get_required_env(...)` looks up. **No mapping table is needed.**
- **ARM lowercases output keys.** `az deployment group show` returns the keys lowercased, so the
  bridge **upper-cases** them (`.key | ascii_upcase`) to restore the names the scripts expect.
- **Scalars only.** A few outputs are arrays/objects (e.g. `FABRIC_ADMIN_MEMBERS`). The
  `select(... type ...)` keeps only string/number/boolean values so nothing multi-line corrupts
  `$GITHUB_ENV`. The skipped outputs are not read as scalar env vars by the scripts.

### Values that are inputs, not outputs

A handful of values the scripts use are **not** Bicep outputs (they are scenario- or
input-derived), so the bridge cannot supply them. Bake these into `_post-deploy.yml`'s
post-provision step as explicit `env:` entries:

| Value                    | Source                                                                 |
|--------------------------|------------------------------------------------------------------------|
| `DATA_FOLDER`            | Set by the chosen scenario (`--scenario <name>`); rarely set directly. |
| `INDUSTRY` / `USECASE`   | Set by the scenario, or pass `--industry/--usecase` for BYOD.          |
| `FABRIC_WORKSPACE_ID`    | **Is** an output when the workspace is created; only needs `extra_env` if you must override it. |

## Step classification

Read the repo's deployment guide (e.g. `documents/DeploymentGuide.md`) and the scripts, then sort
every step into exactly one bucket and **confirm the split with the user** before generating:

| Bucket              | Runs in pipeline? | Examples                                                                 |
|---------------------|-------------------|--------------------------------------------------------------------------|
| **include**         | Yes               | `build-and-push-acr.sh --resource-group …`; `pip install uv && uv pip install -r …/requirements.txt`; `python 00_build_solution.py --from 01 --scenario <name>` |
| **developer-only**  | No (excluded)     | `python 06_test_agent.py` (interactive chat); `az login` / `--use-device-code`; venv create/activate; Codespaces/dev-container/IDE onboarding; any `input()` prompt |
| **manual-post-step**| No (reminder only)| OBO / on-behalf-of auth setup in the portal (`SetupOBOAuthentication.md`), only when `useUserAccessToken=true`; can take ~10 min |

### Non-interactive execution (no script edit)

`00_build_solution.py` has an unconditional `input("Press Enter to start …")` and, for BYOD
scenarios, `input("Industry …")`/`input("Use Case …")`. Drive it non-interactively **without
editing the script**:
- Feed stdin: `printf '\n' | python … 00_build_solution.py …` satisfies the "Press Enter" prompt.
- Choose a scenario: `--scenario <name>` (or `--industry/--usecase`) so no BYOD input branch is
  reached.

## Authentication in CI

The scripts use `AzureCliCredential` (steps 01–02) and `DefaultAzureCredential` (steps 03–05),
both of which resolve the `azure/login` OIDC CLI session — so they run as the **service
principal**, no interactive user token required. Reuse the infra skill's OIDC identity Variables
(`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`).

**Fabric caveat (environmental, not code):** steps that call the Microsoft Fabric API succeed for
a service principal only if the Fabric tenant admin has enabled service-principal access to
Fabric APIs. Surface this to the user.

## CI-identity parameters (values only)

If a solution defaults to a signed-in *user* token, set CI-appropriate **values** in the per-env
`.bicepparam` (never edit Bicep code):

```bicep
param useUserAccessToken = false          // disable OBO/user-token path for unattended CI
// param deployingUserPrincipalType = 'ServicePrincipal'   // if the template consumes it
```

With `useUserAccessToken = false`, the OBO manual post-step is not required.

## Baking the confirmed choices into `_post-deploy.yml`

This skill does **not** emit a separate manifest file. After the classification is confirmed with
the user, substitute the choices directly into `_post-deploy.yml` when rendering it:

| Choice                        | Where it goes in `_post-deploy.yml`                                  |
|-------------------------------|--------------------------------------------------------------------|
| Python version                | `actions/setup-python` `with.python-version`                       |
| Requirements file             | the "Install post-provision dependencies" step                     |
| Build command(s)              | the "Build & push application images" step                         |
| Post-provision entrypoint     | the "Run post-provision" step                                      |
| Scenario + extra flags        | the `--scenario <name>` / `--from …` args on that step             |
| Input-only values (`FABRIC_WORKSPACE_ID`, …) | explicit `env:` on the "Run post-provision" step    |
| Manual post-steps (OBO, …)    | the "Manual post-steps (reminder)" step's `$GITHUB_STEP_SUMMARY`   |

The developer-only smoke test (`06_test_agent.py`) is **excluded** — it is interactive and is not
rendered into the workflow. The classification lives in the workflow itself; there is no manifest
to keep in sync.
