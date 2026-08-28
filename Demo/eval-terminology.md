# WAZA Eval Terminology

Quick reference for terms used in WAZA evaluations.

## Core terms

| Term | What it means |
|------|---------------|
| **Eval** | Short for "evaluation." A full test run that checks whether an AI agent behaves correctly across a set of scenarios. |
| **Task** | A single test case. Each task sends a prompt to the agent and checks the response against expected results. |
| **Fixture** | A fake mini-repository used as the starting environment for a task. Ensures every test begins from a clean, known state. |
| **Trial** | One execution of a task. Running 3 trials means the same task runs 3 times to account for AI non-determinism. |
| **Grader** | A rule that checks the agent's output. Multiple graders can apply to a single task (e.g., check output text AND check tool call count). |
| **Prompt** | The instruction sent to the agent at the start of a task (e.g., "Generate Bicep CI/CD pipelines for this repo"). |
| **Follow-up prompt** | A second question sent to the agent after its initial response, used to probe deeper or confirm behavior. |

## Grader types

| Grader | What it checks |
|--------|----------------|
| **output_contains** | The agent's response includes specific required words or phrases. |
| **output_not_contains** | The agent's response does NOT include certain forbidden words. |
| **output_contains_any** | The agent's response includes at least one word from a list of alternatives. |
| **tool_constraint** | The agent never calls certain dangerous tools (e.g., `delete_file`). |
| **behavior** | The agent stays within limits — max tool calls, max duration, max tokens. |
| **prompt (LLM-as-judge)** | A separate AI model reads the agent's output and grades it against a rubric. |
| **file** | A specific file exists in the workspace after the agent runs. |
| **diff** | The workspace files match an expected snapshot. |

## Task categories

| Category | Meaning |
|----------|---------|
| **Positive test** | The agent SHOULD produce output (e.g., generate pipeline files). A pass means the agent did the right thing. |
| **Negative test** | The agent should NOT produce output (e.g., no pipelines for an empty repo). A pass means the agent correctly refused to act. |
| **Edge case** | An unusual scenario that tests the agent's boundaries (e.g., a repo with no infrastructure at all). |
| **Real-repo test** | A test that runs against the actual codebase instead of a simplified fixture. |

## Result terms

| Term | What it means |
|------|---------------|
| **Pass** | The task met all grading criteria. |
| **Fail** | The task did not meet one or more grading criteria. |
| **Pass rate** | Percentage of trials that passed (e.g., 2 out of 3 trials passed = 67%). |
| **Score** | A number from 0.0 to 1.0 representing how well the agent performed. 1.0 = perfect. |
| **Aggregate score** | The overall score across all tasks in an eval run. |
| **Tool calls** | The number of actions the agent took (reading files, creating files, running commands, etc.). Fewer is generally better. |
| **Duration** | How long the agent took to complete the task. |

## Configuration terms

| Term | What it means |
|------|---------------|
| **eval.yaml** | The main configuration file that defines which tasks to run, which model to use, and global graders. |
| **Executor** | The engine that runs the agent. We use `copilot-sdk` (GitHub Copilot). |
| **Model** | The AI model powering the agent (e.g., `claude-sonnet-4.6`). |
| **Trials per task** | How many times each task runs. More trials = more confidence but longer run time. |
| **Timeout** | Maximum time (in seconds) a task can run before it is stopped. Default is 600 seconds (10 minutes). |
| **Skill** | A set of instructions that teaches the agent how to perform a specific job (e.g., generating Bicep pipelines). |
| **Worktree** | A lightweight Git checkout used to give the agent a copy of the real repository without affecting the original. |

## Dashboard terms

| Term | What it means |
|------|---------------|
| **Dashboard** | A web UI (started with `waza serve`) that visualizes eval results in a browser. |
| **Results JSON** | The raw output file from a `waza run`. Contains all scores, tool calls, and agent responses. |
| **RESULTS.md** | A Markdown summary generated from the results JSON by `generate_report.py`. |
