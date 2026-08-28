"""Read the latest Waza results JSON and write waza-evals/RESULTS.md."""
import json, glob, os, sys

script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(script_dir)
patterns = [
    os.path.join(script_dir, "results*.json"),
    os.path.join(repo_root, "waza-evals", "results*.json"),
]
results_files = []
for p in patterns:
    results_files.extend(glob.glob(p))
results_files = sorted(set(results_files), key=os.path.getmtime)
if not results_files:
    print("No results files found")
    sys.exit(0)

latest = results_files[-1]
data = json.load(open(latest, encoding="utf-8"))

s = data["summary"]
c = data["config"]
lines = [
    "# Waza evaluation results",
    "",
    f"**Run:** {data.get('timestamp', 'N/A')}  ",
    f"**Model:** {c['model_id']}  ",
    f"**Executor:** {c['engine_type']}  ",
    f"**Trials per task:** {c['runs_per_test']}  ",
    f"**Pass rate:** {s['success_rate']*100:.1f}%  ",
    f"**Aggregate score:** {s['aggregate_score']:.2f}  ",
    f"**Duration:** {s['duration_ms']/1000:.0f}s  ",
    "",
    "## Per-task results",
    "",
    "| Task | Status | Pass rate | Avg score | Avg duration |",
    "|------|--------|-----------|-----------|--------------|",
]

for task in data.get("tasks", []):
    passed = task["status"] == "passed"
    icon = "PASS" if passed else "FAIL"
    runs = task.get("runs", [])
    n_pass = sum(1 for r in runs if r.get("status") == "passed")
    pass_pct = (n_pass / max(len(runs), 1)) * 100
    scores = []
    for r in runs:
        vs = r.get("validations") or {}
        task_scores = [v.get("score", 0) for v in vs.values()]
        scores.append(sum(task_scores) / max(len(task_scores), 1))
    avg_score = sum(scores) / max(len(scores), 1)
    avg_dur = sum(r.get("duration_ms", 0) for r in runs) / max(len(runs), 1)
    lines.append(
        f"| {task['display_name']} | {icon} | {pass_pct:.0f}% | "
        f"{avg_score:.2f} | {avg_dur/1000:.0f}s |"
    )

# Token usage
u = s.get("usage")
if u:
    lines += [
        "",
        "## Token usage",
        "",
        "| Metric | Value |",
        "|--------|-------|",
        f"| Premium requests | {u.get('premium_requests', 0)} |",
        f"| Input tokens | {u.get('input_tokens', 0):,} |",
        f"| Output tokens | {u.get('output_tokens', 0):,} |",
        f"| Cached read | {u.get('cache_read_tokens', 0):,} |",
        f"| Total tokens | {u.get('input_tokens', 0) + u.get('output_tokens', 0):,} |",
    ]

# Failed task details
failed = [t for t in data.get("tasks", []) if t["status"] != "passed"]
if failed:
    lines += ["", "## Failed tasks", ""]
    for t in failed:
        lines.append(f"### {t['display_name']}")
        lines.append("")
        for r in t.get("runs", []):
            for name, v in (r.get("validations") or {}).items():
                if not v.get("passed", True):
                    lines.append(f"- **{name}**: {v.get('feedback', 'failed')}")
        lines.append("")
else:
    lines += ["", "All tasks passed."]

lines.append("")
out_path = os.path.join(script_dir, "RESULTS.md")
with open(out_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print(f"Report written to {out_path}")
