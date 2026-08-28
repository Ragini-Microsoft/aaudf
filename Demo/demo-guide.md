# WAZA Evals Guide

## Overview

We built an AI agent (a GitHub Copilot custom agent) that generates Azure DevOps CI/CD pipelines for our infrastructure. Before we trust its output, we need to verify that it works correctly every time. **WAZA** is the tool that does this verification automatically.

Think of it like a **quality checklist that runs itself** — it gives the agent a task, watches what it does, and grades the result as PASS or FAIL.

## Prerequisites

| Tool | Minimum version | Purpose |
|------|-----------------|---------|
| VS Code | Latest stable | IDE with Copilot integration |
| GitHub Copilot | Active subscription | Agent runtime (Copilot SDK) |
| GitHub CLI (`gh`) | Latest | Authentication with GitHub |
| Git | Latest | Worktree-based test fixtures |
| Python | 3.10+ | Report generation script |
| Node.js | 18+ | Copilot SDK dependency |

## Key concepts

### Tasks

A **task** is a single test case for the agent. Each task is a small YAML file that defines:

- **Prompt** — the instruction given to the agent (e.g., "Generate Bicep CI/CD pipelines for this repo").
- **Expected output** — keywords or phrases the agent's response must contain (e.g., "bicep-ci.yml").
- **Grading rules** — what counts as a pass or fail (e.g., the agent must not exceed 80 tool calls).

We have **15 tasks** covering different scenarios — Bicep, Terraform, post-deploy, safety, and edge cases. Each task runs independently so we can pinpoint exactly which scenario fails.

### Fixtures

A **fixture** is a fake mini-repository that WAZA creates for each test. Instead of running the agent against our real codebase (which is large and complex), fixtures give the agent a small, controlled environment.

| Fixture | What it contains | Used by |
|---------|-----------------|---------|
| `bicep-fresh` | Only Bicep infrastructure files, no pipelines | Bicep scenarios |
| `terraform-fresh` | Only Terraform infrastructure files, no pipelines | Terraform scenarios |
| `both-fresh` | Both Bicep and Terraform files, no pipelines | Combined scenarios |
| `no-infra` | An empty repository with no infrastructure at all | Negative/edge-case scenarios |

Fixtures ensure each test starts from a clean, known state — so results are repeatable and not affected by leftover files.

## Setup (first-time only)

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

## Prerequisites check

Before running any scenarios, verify your setup:

```powershell
waza --version    # should show 0.38.7 or later
gh auth status    # should show authenticated
```

## Evaluation scenarios

### Scenario 1: Bicep pipeline generation

Verifies that the agent detects Bicep infrastructure in a fresh repository and generates the correct CI/CD pipeline YAML files.

```powershell
waza run waza-evals/eval.yaml --task "bicep-generates*" --trials 1 -v -o waza-evals/results-test.json
```

The `-o` flag saves results to a JSON file for the dashboard and report generator.

**Expected result:** PASS — the agent creates pipeline files like `bicep-ci.yml` and `bicep-deploy.yml`.

### Scenario 2: Terraform pipeline generation

Verifies that the agent detects Terraform infrastructure and generates the appropriate pipeline YAML files (not Bicep ones).

```powershell
waza run waza-evals/eval.yaml --task "terraform-generates*" --trials 1 -v -o waza-evals/results-test.json
```

**Expected result:** PASS — the agent creates Terraform-specific pipeline files.

### Scenario 3: Empty repository (negative test)

Verifies that the agent correctly does nothing when the repository has no infrastructure files. It should not hallucinate or generate unnecessary files.

```powershell
waza run waza-evals/eval.yaml --task "no-infra*" --trials 1 -v -o waza-evals/results-test.json
```

**Expected result:** PASS — the agent reports "no infrastructure found" and creates no pipeline files.

### Scenario 4: Full regression suite (all 15 tests)

Runs the complete evaluation suite covering all categories:

```powershell
waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json
```

This takes approximately 5-10 minutes.

| Category | Tests | What they verify |
|----------|-------|------------------|
| Bicep | 2 | Agent generates correct Bicep pipelines |
| Terraform | 2 | Agent generates correct Terraform pipelines |
| Both | 1 | Agent handles repos with both Bicep and Terraform |
| Structure | 3 | Cleanup stage, schedule, and variable groups are correct |
| Post-deploy | 2 | Post-deployment testing stage is generated |
| Safety | 1 | Agent never modifies source infrastructure files |
| Edge case | 1 | Agent handles empty repos correctly |
| Real repo | 3 | Agent works correctly on our actual codebase |

### Scenario 5: View results in the dashboard

After running any scenario, start the web dashboard to visualize results:

```powershell
waza serve --results-dir waza-evals --port 3000
```

Open `http://localhost:3000` in your browser. The dashboard shows:

- PASS/FAIL status and score for each test.
- Detailed agent responses (click into any test to expand).
- Score consistency across multiple trials.

Press `Ctrl+C` in the terminal to stop the dashboard.

### Scenario 6: Generate a Markdown report

Instead of the dashboard, you can generate a summary as a Markdown file:

```powershell
python waza-evals/generate_report.py
```

This reads the latest `results*.json` from the `waza-evals/` directory and writes `waza-evals/RESULTS.md` with pass rates, scores, and per-task breakdowns.

## Understanding results

- **Pass rate** — percentage of tests that passed (e.g., "14/15 = 93%").
- **Score** — a number from 0.0 to 1.0. A score of 1.0 means the agent met all grading criteria.
- **Tool calls** — how many actions the agent took (reading files, creating files, etc.). Fewer is generally better.

## FAQ

**Q: Why do we need this?**
A: AI agents are non-deterministic — they can give different answers each time. Automated evals give us confidence that the agent works reliably before we ship it.

**Q: How often do we run these tests?**
A: We can run them on every code change (in CI/CD), on a daily schedule, or on-demand before a release.

**Q: What happens when a test fails?**
A: We investigate the failure, fix the agent's instructions or skills, and re-run the tests to confirm the fix.

**Q: What model is the agent using?**
A: The eval is configured to use `claude-sonnet-4.6` (defined in `eval.yaml`), but we can test against any model supported by GitHub Copilot.

**Q: Can we add more tests?**
A: Yes. Each test is a simple YAML file that describes a prompt, the expected output, and grading rules. No coding required.

## Quick reference

| What you want to do | Command |
|----------------------|---------|
| Run one scenario | `waza run waza-evals/eval.yaml --task "test-name*" --trials 1 -v -o waza-evals/results-test.json` |
| Run all scenarios | `waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json` |
| Run with 3 trials | `waza run waza-evals/eval.yaml --trials 3 -v -o waza-evals/results-test.json` |
| Open dashboard | `waza serve --results-dir waza-evals --port 3000` |
| Generate markdown report | `python waza-evals/generate_report.py` |
| Check WAZA version | `waza --version` |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `waza: command not found` | Run `$env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"` |
| Authentication error | Run `gh auth login` then `copilot login` |
| Test times out | Increase `timeout_seconds` in `eval.yaml` or use `--trials 1` |
| Dashboard won't open | Check port 3000 is free: `netstat -ano \| findstr :3000` |
| All tests fail | Check internet connection and GitHub auth: `gh auth status` |
