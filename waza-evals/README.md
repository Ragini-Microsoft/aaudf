# Waza evaluation: ADO CICD Infra Workflows agent

Standalone Waza evaluation suite for the **ADO CICD Infra Workflows** Copilot
agent. Validates that the agent correctly detects infrastructure, generates
Azure DevOps CI/CD pipeline YAML files, and follows structural requirements.

## Agent under test

**ADO CICD Infra Workflows** (`.github/agents/ado-cicd-workflows.agent.md`)

### Skills exercised

| Skill | Purpose |
|---|---|
| `ado-cicd-bicep-workflows` | Bicep CI + deploy pipelines |
| `ado-cicd-terraform-workflows` | Terraform CI + deploy pipelines |
| `ado-cicd-post-deploy` | Post-deploy + test stage |

## Architecture

```
                    Waza
                      │
                      ▼
                Copilot SDK
                      │
                      ▼
        ADO CICD Infra Workflows
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Bicep      Terraform   Post-Deploy
       Skill        Skill        Skill
          │           │           │
          └───────────┼───────────┘
                      ▼
              Generated YAML
         (temp workspace per task)
                      │
                      ▼
       .azuredevops/pipelines/
                      │
             ┌────────┴────────┐
             ▼                 ▼
       YAML validation    Behavior grading
             │                 │
             └────────┬────────┘
                      ▼
               RESULTS.md
                      │
                      ▼
              Waza Dashboard
```

## Prerequisites

- **Waza CLI** v0.38.7+ (`waza --version`)
- **GitHub Copilot** authentication (`copilot login` via the embedded CLI at `%LOCALAPPDATA%\copilot-sdk\`)
- **GitHub CLI** authenticated (`gh auth login`)
- **Git** (for worktree-based fixtures)
- **Python** (for `generate_report.py`)
- **Waza on PATH**: `$env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"`

## Evaluation tasks

| # | Task ID | Category | Type | What it validates |
|---|---------|----------|------|-------------------|
| 1 | `bicep-generates-yaml` | Bicep | Positive | Agent creates Bicep CI + deploy .yml files |
| 2 | `bicep-yaml-has-correct-structure` | Bicep | Positive | YAML has stages, variable group, cleanup, schedule |
| 3 | `terraform-generates-yaml` | Terraform | Positive | Agent creates Terraform CI + deploy .yml files |
| 4 | `terraform-yaml-has-correct-structure` | Terraform | Positive | YAML has stages, variable group, cleanup |
| 5 | `both-generates-yaml` | Both | Positive | Agent generates pipelines for both Bicep + Terraform |
| 6 | `cleanup-always-present` | Structure | Positive | Cleanup stage uses `condition: always()` |
| 7 | `schedule-ist-correct` | Structure | Positive | Schedule uses `cron: 30 18 * * *` (00:00 IST) |
| 8 | `variable-group-correct` | Structure | Positive | Uses `bicep-deploy` and `terraform-deploy` |
| 9 | `no-source-files-modified` | Safety | Positive | Agent does not modify .bicep/.tf source files |
| 10 | `no-infra-no-generation` | Edge case | Negative | No Bicep/Terraform pipeline generated for empty repo |
| 11 | `real-repo-detects-both` | Real repo | Positive | Detects both Bicep + Terraform in the actual repo |
| 12 | `real-repo-reports-existing` | Real repo | Positive | Reports the 7 existing pipeline files correctly |
| 13 | `real-repo-variable-groups` | Real repo | Positive | Finds bicep-deploy + terraform-deploy in real YAML |
| 14 | `post-deploy-generates-yaml` | Post-deploy | Positive | Agent generates post-deploy stage template |
| 15 | `post-deploy-has-correct-structure` | Post-deploy | Positive | PostDeployTest has dependsOn chain + Cleanup |

Tasks 1-10 use **fixture workspaces** (simplified infra, no existing pipelines)
to test fresh YAML generation. Tasks 11-13 use **git worktree** of the real
repository to test agent behavior on actual infrastructure.

## Graders

| Grader | Type | Scope | What it checks |
|--------|------|-------|----------------|
| `no_destructive_tools` | `tool_constraint` | Eval | Agent never calls `delete_file` |
| `_output_contains` | `expected` | Task | Required strings present in agent output |
| `_output_contains_any` | `expected` | Task | At least one alternative string present |
| `_output_not_contains` | `expected` | Task | Forbidden strings absent from output |
| `behavior` | `expected` | Task | Tool call limits per task |

## Trials

Each task runs **3 trials** (`config.trials_per_task: 3`) to account for
non-deterministic agent behavior. Override with `--trials 1` for quick runs.

## Running the evaluation

All commands assume you are in the repository root.

### Run all tasks

```powershell
waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-bicep-test.json
```

### Run a single Bicep task

```powershell
waza run waza-evals/eval.yaml --task "bicep-generates*" --trials 1 -v
```

### Run a single Terraform task

```powershell
waza run waza-evals/eval.yaml --task "terraform-generates*" --trials 1 -v
```

### Run edge cases only

```powershell
waza run waza-evals/eval.yaml --tags "edge-case" --trials 1 -v
```

### Run structure validation only

```powershell
waza run waza-evals/eval.yaml --tags "structure" --trials 1 -v
```

### Keep workspace to inspect generated YAML

```powershell
waza run waza-evals/eval.yaml --task "bicep-generates*" --trials 1 -v --keep-workspace
```

Generated files appear in a temp folder printed in the output (e.g.
`%TEMP%\waza-XXXXX\.azuredevops\pipelines\`).

### Generate results report

```powershell
python waza-evals/generate_report.py
```

Reads the latest `results*.json` and writes `waza-evals/RESULTS.md`.

## Waza dashboard

View evaluation results visually in the built-in web dashboard:

```powershell
waza serve --results-dir waza-evals --port 3000
```

Opens `http://localhost:3000` with:

- Task-level pass/fail status and scores
- Grader detail breakdown per task
- Token usage and duration metrics
- Run history and trends

## Compare runs across models

Test the agent against different models and compare:

```powershell
waza run waza-evals/eval.yaml --model claude-sonnet-4.6 --trials 1 -v -o waza-evals/results-sonnet.json
waza run waza-evals/eval.yaml --model gpt-5.4 --trials 1 -v -o waza-evals/results-gpt54.json
waza compare waza-evals/results-sonnet.json waza-evals/results-gpt54.json
```

Track quality improvement across agent versions:

```
Agent v1 → Pass rate: 72%
Agent v2 → Pass rate: 88%
Agent v3 → Pass rate: 100%
```

## Spec verification

Verify that the eval covers every requirement from the skill definition:

```powershell
waza spec verify --skill .agents/skills/ado-cicd-bicep-workflows --eval waza-evals/eval.yaml
waza spec verify --skill .agents/skills/ado-cicd-terraform-workflows --eval waza-evals/eval.yaml
```

Reports which skill requirements have matching evaluation tasks and which are
uncovered.

## Suggest additional tests

Let Waza analyze the skill and propose test cases:

```powershell
waza suggest .agents/skills/ado-cicd-bicep-workflows --dry-run
waza suggest .agents/skills/ado-cicd-terraform-workflows --dry-run
```

Use `--apply` to write the suggested tasks to disk.

## Fixtures

Each task gets a **fresh temporary workspace** with fixture files copied in.
The agent generates YAML into that workspace. The original repo is never
modified.

| Fixture | Contents | Used by |
|---------|----------|---------|
| `fixtures/bicep-fresh/` | `infra/main.bicep` + `main.parameters.json` | Bicep tasks |
| `fixtures/terraform-fresh/` | `infra_tf/main.tf` + `variables.tf` + `providers.tf` + `outputs.tf` | Terraform tasks |
| `fixtures/both-fresh/` | Both Bicep + Terraform infra, no pipelines | Both-flavors task |
| `fixtures/no-infra/` | `src/app.py` + `package.json` only | No-infra edge case |

## Validation criteria

**Bicep pipelines:** Agent generates `.yml` files with `bicep-deploy` variable
group, service connection reference, `az deployment` steps.

**Terraform pipelines:** Agent generates `.yml` files with `terraform-deploy`
variable group, service connection reference, `terraform` steps.

**Cleanup:** Every deploy pipeline has a Cleanup stage with
`condition: always()` to delete the resource group.

**Schedule:** Deploy pipelines use `cron: "30 18 * * *"` (00:00 IST).

**Safety:** Agent never modifies `.bicep`, `.tf`, or `.tfvars` source files.

## Limitation

The evaluation validates **generated YAML artifacts and agent behavior only**.
It does **not** execute the generated Azure DevOps pipelines.

```
Agent  →  Generate YAML  →  Validate YAML  →  Evaluate behavior  ✓
Agent  →  Generate YAML  →  Commit  →  Push  →  Run ADO pipeline   ✗
```

### Future extension

When pipeline execution permissions become available:

1. Push generated YAML to a test branch
2. Trigger the ADO pipeline via API
3. Validate pipeline execution results
4. Verify resource group creation and cleanup

## File structure

```
waza-evals/
├── README.md                              # This file
├── eval.yaml                              # Main evaluation spec
├── generate_report.py                     # Auto-generates RESULTS.md from JSON
├── RESULTS.md                             # Latest evaluation results
├── tasks/
│   ├── bicep-generates-yaml.yaml          # Bicep YAML generation
│   ├── bicep-yaml-has-correct-structure.yaml
│   ├── terraform-generates-yaml.yaml      # Terraform YAML generation
│   ├── terraform-yaml-has-correct-structure.yaml
│   ├── both-generates-yaml.yaml           # Both flavors
│   ├── cleanup-always-present.yaml        # Cleanup always()
│   ├── schedule-ist-correct.yaml          # 00:00 IST schedule
│   ├── variable-group-correct.yaml        # Variable group naming
│   ├── no-source-files-modified.yaml      # No infra edits
│   ├── no-infra-no-generation.yaml        # Empty repo edge case
│   ├── real-repo-detects-both.yaml        # Real repo: detect both flavors
│   ├── real-repo-reports-existing.yaml    # Real repo: report existing pipelines
│   ├── real-repo-variable-groups.yaml     # Real repo: variable group names
│   ├── post-deploy-generates-yaml.yaml    # Post-deploy stage generation
│   └── post-deploy-has-correct-structure.yaml  # Post-deploy dependsOn chain
├── fixtures/
│   ├── bicep-fresh/                       # Bicep infra, no pipelines
│   │   └── infra/
│   ├── terraform-fresh/                   # Terraform infra, no pipelines
│   │   └── infra_tf/
│   ├── both-fresh/                        # Both infra, no pipelines
│   │   ├── infra/
│   │   └── infra_tf/
│   └── no-infra/                          # App only, no infra
│       └── src/
└── results-bicep-test.json                # Latest results JSON
```
