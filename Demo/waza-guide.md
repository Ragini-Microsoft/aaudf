# WAZA: AI Agent Evaluation Framework

## What is WAZA?

WAZA is a CLI-based evaluation framework developed by Microsoft that tests and validates AI agents (such as GitHub Copilot custom agents) by running structured tasks against them, grading the outputs, and producing a results dashboard. It automates the process of verifying that an agent behaves correctly — generating the right files, calling the right tools, and avoiding destructive actions.

In this repository, WAZA evaluates the **ADO CICD Infra Workflows** agent, which generates Azure DevOps pipeline YAML for Bicep and Terraform infrastructure.

waza reference video - [click here](https://www.youtube.com/watch?v=jOw6d5zH658)

## Prerequisites

| Tool | Minimum version | Purpose |
|------|-----------------|---------|
| VS Code | Latest stable | IDE with Copilot integration |
| GitHub Copilot | Active subscription | Agent runtime (Copilot SDK) |
| GitHub CLI (`gh`) | Latest | Authentication with GitHub |
| Git | Latest | Worktree-based test fixtures |
| Python | 3.10+ | Report generation script |
| Node.js | 18+ | Copilot SDK dependency |

## Setup

### Step 1: Download and install WAZA

WAZA is an open-source CLI from Microsoft hosted at [github.com/microsoft/waza](https://github.com/microsoft/waza).

**Option A: PowerShell one-liner (recommended for Windows)**

Open a PowerShell terminal and run:

```powershell
irm https://raw.githubusercontent.com/microsoft/waza/main/install.ps1 | iex
```

This downloads the latest Windows binary, verifies the checksum, and installs it to `%LOCALAPPDATA%\Microsoft\Waza`.

**Option B: Bash install (Git Bash / WSL / macOS / Linux)**

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash
```

> **Important:** Do not run the Bash command from PowerShell — it may invoke WSL and install the Linux binary instead of the Windows one.

**Option C: Download manually**

Go to the [GitHub Releases](https://github.com/microsoft/waza/releases) page, download the `waza` binary for your OS/architecture, and place it somewhere on your system.

### Step 2: Add WAZA to PATH

After installation, add the install directory to your PATH so the `waza` command is available in every terminal session:

```powershell
# Add to current session
$env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"
```

To make this permanent, add `%LOCALAPPDATA%\Microsoft\Waza` to your user PATH via **Settings > System > About > Advanced system settings > Environment Variables**.

Verify it works:

```powershell
waza --version
```

Confirm the version is **0.38.7 or later**.

### Step 3: Authenticate with GitHub

WAZA requires GitHub authentication through two tools:

```powershell
# Authenticate GitHub CLI
gh auth login
# Follow the browser-based OAuth flow
```

```powershell
# Authenticate Copilot SDK (located at %LOCALAPPDATA%\copilot-sdk\)
copilot login
# This opens a device-code flow in the browser
```

Verify authentication:

```powershell
gh auth status
```

### Step 4: Install Python dependencies (for report generation)

```powershell
pip install pyyaml
```

### Updating WAZA

After the initial install, update to the latest version at any time:

```powershell
waza update
```

## Project structure

```
waza-evals/
├── eval.yaml              # Main evaluation config (tasks, graders, model)
├── generate_report.py     # Converts results JSON → RESULTS.md
├── fixtures/              # Isolated test workspaces
│   ├── bicep-fresh/       # Repo with only Bicep infra, no pipelines
│   ├── terraform-fresh/   # Repo with only Terraform infra, no pipelines
│   ├── both-fresh/        # Repo with Bicep + Terraform, no pipelines
│   └── no-infra/          # Empty repo (negative test)
└── tasks/                 # Individual evaluation task definitions
    ├── bicep-generates-yaml.yaml
    ├── terraform-generates-yaml.yaml
    ├── post-deploy-generates-yaml.yaml
    └── ... (15 tasks total)
```

## How WAZA works

1. **eval.yaml** defines the evaluation: model, executor, graders, and a glob pointing to task files.
2. Each **task YAML** specifies a prompt, a fixture workspace, expected outputs, and grading criteria.
3. WAZA spins up the agent inside the Copilot SDK, sends the prompt, and captures the agent's tool calls and text output.
4. **Graders** check the results:
   - `tool_constraint` — blocks destructive tools like `delete_file`.
   - `expected` / `output_contains` — required strings in agent output.
   - `output_not_contains` — forbidden strings.
   - `behavior` — max tool call limits.
5. Each task runs multiple **trials** (default 3) to account for non-determinism.
6. Results are written to a JSON file and can be viewed in the **Waza Dashboard** or converted to Markdown.

## Running evaluations

### Run all tasks

```powershell
cd "c:\A GSA\Ragini-AAUDF\aaudf"
waza run waza-evals/eval.yaml --trials 3 -v
```

### Run and save results to a JSON file

Use `-o` to save results for later viewing in the dashboard or for report generation:

```powershell
waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json
```

### Run a subset of tasks (by glob)

```powershell
# Only post-deploy tasks
waza run waza-evals/eval.yaml --task "post-deploy*" --trials 1 -v -o waza-evals/results-test.json

# Only Bicep tasks
waza run waza-evals/eval.yaml --task "bicep*" --trials 1 -v -o waza-evals/results-test.json

# Only real-repo tasks
waza run waza-evals/eval.yaml --task "real-repo*" --trials 1 -v -o waza-evals/results-test.json
```

### Run with a single trial (faster iteration)

```powershell
waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json
```

## Viewing results

### Option 1: Waza Dashboard (browser UI)

```powershell
waza serve --results-dir waza-evals --port 3000
```

Open `http://localhost:3000` in your browser.

### Option 2: Generate a Markdown report

```powershell
python waza-evals/generate_report.py
```

This reads the latest `results*.json` and writes `waza-evals/RESULTS.md` with pass rates, scores, and per-task breakdowns.

## Writing a new task

Create a YAML file under `waza-evals/tasks/`:

```yaml
id: my-new-task
name: "Positive: describe what the task validates"
description: >-
  Full description of the scenario.
tags:
  - bicep
  - positive

inputs:
  prompt: >-
    The instruction sent to the agent.
  context:
    fixture: fixtures/bicep-fresh
  follow_up_prompts:
    - "Any follow-up question for the agent."

expected:
  output_contains:
    - "string that must appear in agent output"
  output_not_contains:
    - "string that must NOT appear"
  behavior:
    max_tool_calls: 80
```

Then run it:

```powershell
waza run waza-evals/eval.yaml --task "my-new-task" --trials 1 -v -o waza-evals/results-test.json
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `waza: command not found` | Add WAZA to PATH: `$env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"` |
| `copilot login` fails | Re-authenticate: `gh auth login`, then retry `copilot login` |
| Tasks time out | Increase `config.timeout_seconds` in `eval.yaml` (default 600) |
| `No results files found` | Run `waza run` first; results JSON is created in the `waza-evals/` directory |
| Dashboard won't start | Check port 3000 is free: `netstat -ano | findstr :3000` |
