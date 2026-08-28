# WAZA Evals Demo Guide

> **Audience:** Program managers, stakeholders, and non-technical team members.
> This guide walks you through a live demo of how we use WAZA to test our AI agent automatically.

## What are we demoing?

We built an AI agent (a Copilot custom agent) that generates Azure DevOps CI/CD pipelines for our infrastructure. Before we trust its output, we need to verify that it works correctly every time. **WAZA** is the tool that does this verification automatically.

Think of it like a **quality checklist that runs itself** — it gives the agent a task, watches what it does, and grades the result as PASS or FAIL.

## Key concepts: Tasks and Fixtures

Before jumping into the demo, here are two terms you will hear frequently:

### Tasks

A **task** is a single test case for the agent. Each task is a small YAML file that says:

- **Prompt** — the instruction to give the agent (e.g., "Generate Bicep CI/CD pipelines for this repo").
- **Expected output** — keywords or phrases the agent's response must contain (e.g., "bicep-ci.yml").
- **Grading rules** — what counts as a pass or fail (e.g., the agent must not exceed 80 tool calls).

We have **15 tasks** covering different scenarios — Bicep, Terraform, post-deploy, safety, and edge cases. Each task runs independently so we can pinpoint exactly which scenario fails.

### Fixtures

A **fixture** is a fake mini-repository that WAZA creates for each test. Instead of running the agent against our real codebase (which is large and complex), fixtures give the agent a small, controlled environment.

| Fixture | What it contains | Used by |
|---------|-----------------|---------|
| `bicep-fresh` | Only Bicep infrastructure files, no pipelines | Bicep tests |
| `terraform-fresh` | Only Terraform infrastructure files, no pipelines | Terraform tests |
| `both-fresh` | Both Bicep and Terraform files, no pipelines | Combined tests |
| `no-infra` | An empty repository with no infrastructure at all | Negative/edge-case tests |

Fixtures ensure each test starts from a clean, known state — so results are repeatable and not affected by leftover files.

## What you will show in the demo

| # | What you show | What it proves | Time |
|---|---------------|----------------|------|
| 1 | Run a single Bicep test | Agent can generate pipeline files for Bicep infrastructure | 2 min |
| 2 | Run a single Terraform test | Agent can generate pipeline files for Terraform infrastructure | 2 min |
| 3 | Run a negative test | Agent correctly does nothing when there is no infrastructure | 2 min |
| 4 | Run all 15 tests at once | Full regression suite passes | 5 min |
| 5 | Open the results dashboard | Visual summary of pass/fail and scores | 1 min |

## Before the demo

Make sure these are ready on your machine:

1. Open **VS Code** with the `aaudf` repository folder.
2. Open a **terminal** inside VS Code (`` Ctrl+` ``).
3. Confirm WAZA is on PATH:

   ```powershell
   waza --version
   ```

   You should see `waza version 0.38.7` or later. If not, run:

   ```powershell
   $env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"
   ```

4. Confirm you are authenticated:

   ```powershell
   gh auth status
   ```

## Demo script

### Demo 1: Run a single Bicep test

**What to say:** "Let's ask the agent to generate Bicep CI/CD pipelines for a fresh repository that has no pipelines yet, and see if it passes."

**What to run:**

```powershell
waza run waza-evals/eval.yaml --task "bicep-generates*" --trials 1 -v -o waza-evals/results-test.json
```

> The `-o` flag saves results to a JSON file so the dashboard and report generator can read them later.

**What happens:** WAZA gives the agent a fake repository with only Bicep infrastructure files. The agent analyzes it and generates pipeline YAML files. WAZA then checks that the output mentions the expected file names (like `bicep-ci.yml` or `bicep-deploy.yml`).

**What to point out:**
- The `PASS` or `FAIL` status at the end.
- The score (1.0 = perfect).
- The number of tool calls the agent made.

---

### Demo 2: Run a single Terraform test

**What to say:** "Now let's do the same thing but for a repository with Terraform infrastructure instead of Bicep."

**What to run:**

```powershell
waza run waza-evals/eval.yaml --task "terraform-generates*" --trials 1 -v -o waza-evals/results-test.json
```

**What to point out:** The agent correctly detects Terraform (not Bicep) and generates the appropriate pipeline files.

---

### Demo 3: Run a negative test (empty repo)

**What to say:** "What if someone gives the agent a repository with no infrastructure at all? It should say 'there's nothing to do' — not generate random files."

**What to run:**

```powershell
waza run waza-evals/eval.yaml --task "no-infra*" --trials 1 -v -o waza-evals/results-test.json
```

**What to point out:** The agent correctly reports that no infrastructure was found. This proves the agent does not hallucinate or generate unnecessary files.

---

### Demo 4: Run the full test suite (all 15 tests)

**What to say:** "We have 15 automated tests covering Bicep, Terraform, post-deploy, safety checks, and edge cases. Let's run them all."

**What to run:**

```powershell
waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json
```

> This takes approximately 5-10 minutes. You can talk through the tests while they run.

**What to point out while tests are running:**

| Category | Tests | What they check |
|----------|-------|-----------------|
| Bicep | 2 tests | Agent generates correct Bicep pipelines |
| Terraform | 2 tests | Agent generates correct Terraform pipelines |
| Both | 1 test | Agent handles repos with both Bicep and Terraform |
| Structure | 3 tests | Cleanup stage, schedule, variable groups are correct |
| Post-deploy | 2 tests | Post-deployment testing stage is generated |
| Safety | 1 test | Agent never modifies source infrastructure files |
| Edge case | 1 test | Agent handles empty repos correctly |
| Real repo | 3 tests | Agent works correctly on our actual codebase |

**When tests finish, point out:**
- Overall pass rate (e.g., "14 out of 15 passed = 93%").
- Any failures and what they mean.

---

### Demo 5: Open the results dashboard

**What to say:** "WAZA also has a web dashboard where we can visualize results."

**What to run:**

```powershell
waza serve --results-dir waza-evals --port 3000
```

**What to do:** Open your browser to `http://localhost:3000`.

**What to point out:**
- Each test shows PASS/FAIL with a score.
- You can click into individual tests to see what the agent said.
- Scores across multiple trials show consistency.

> Press `Ctrl+C` in the terminal to stop the dashboard when done.

## Talking points for Q&A

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

## Quick reference commands

| What you want to do | Command |
|----------------------|---------|
| Run one test | `waza run waza-evals/eval.yaml --task "test-name*" --trials 1 -v -o waza-evals/results-test.json` |
| Run all tests | `waza run waza-evals/eval.yaml --trials 1 -v -o waza-evals/results-test.json` |
| Run with 3 trials (more reliable) | `waza run waza-evals/eval.yaml --trials 3 -v -o waza-evals/results-test.json` |
| Open dashboard | `waza serve --results-dir waza-evals --port 3000` |
| Generate markdown report | `python waza-evals/generate_report.py` |
| Check WAZA version | `waza --version` |

## If something goes wrong during the demo

| Problem | Quick fix |
|---------|-----------|
| `waza: command not found` | Run `$env:Path += ";$env:LOCALAPPDATA\Microsoft\Waza"` |
| Authentication error | Run `gh auth login` then `copilot login` |
| Test times out | Add `--trials 1` to run faster with a single trial |
| Dashboard won't open | Check port 3000 is free: `netstat -ano \| findstr :3000` |
| All tests fail | Check internet connection and GitHub auth: `gh auth status` |
