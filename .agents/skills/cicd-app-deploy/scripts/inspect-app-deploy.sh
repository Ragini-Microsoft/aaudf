#!/usr/bin/env bash
# ============================================================================
# inspect-app-deploy.sh — read-only discovery of a solution's app-deploy layer.
#
# Emits a single JSON object (app-facts.json) describing the post-provision
# steps so the cicd-app-deploy skill can classify them and render
# _app-deploy.yml. Makes NO changes to the repo.
#
# Portable Bash (macOS Bash 3.2 + Windows Git Bash/WSL). Requires: jq.
# Usage: inspect-app-deploy.sh [repo_root] > .agent/tmp/app-facts.json
# ============================================================================
set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"
cd "$REPO_ROOT"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required." >&2; exit 1; }

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
# First existing path from a list (prints path or empty).
first_existing() {
  for p in "$@"; do
    [ -e "$p" ] && { echo "$p"; return 0; }
  done
  echo ""
}

# JSON array of files matching a glob under a dir (portable; no mapfile).
json_files() {
  local dir="$1" pattern="$2" out="[]" f
  if [ -d "$dir" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      out="$(echo "$out" | jq --arg f "$f" '. + [$f]')"
    done <<EOF
$(find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null | sort)
EOF
  fi
  echo "$out"
}

grep_q() { grep -q -e "$1" -- "$2" 2>/dev/null; }

# ----------------------------------------------------------------------------
# Deployment guide
# ----------------------------------------------------------------------------
GUIDE="$(first_existing \
  documents/DeploymentGuide.md \
  docs/DeploymentGuide.md \
  DeploymentGuide.md \
  documents/deployment-guide.md)"

# ----------------------------------------------------------------------------
# Image-build scripts (infra/scripts/build/*)
# ----------------------------------------------------------------------------
BUILD_DIR="$(first_existing infra/scripts/build src/scripts/build scripts/build)"
BUILD_SH="[]"; BUILD_PS1="[]"; BUILD_RG_ARG="false"; BUILD_PRIMARY=""
if [ -n "$BUILD_DIR" ]; then
  BUILD_SH="$(json_files "$BUILD_DIR" '*.sh')"
  BUILD_PS1="$(json_files "$BUILD_DIR" '*.ps1')"
  BUILD_PRIMARY="$(echo "$BUILD_SH" | jq -r '.[0] // ""')"
  if [ -n "$BUILD_PRIMARY" ] && grep_q '--resource-group' "$BUILD_PRIMARY"; then
    BUILD_RG_ARG="true"
  fi
fi

# ----------------------------------------------------------------------------
# Post-provision entrypoint, requirements, dev-only scripts
# ----------------------------------------------------------------------------
PP_DIR="$(first_existing infra/scripts/post-provision infra/scripts/postprovision scripts/post-provision)"
PP_ENTRY=""; PP_REQS=""; PP_TEST=""; PP_INPUT_PROMPTS="0"; PP_ENTRY_ARGS="[]"
if [ -n "$PP_DIR" ]; then
  PP_ENTRY="$(first_existing "$PP_DIR/00_build_solution.py" "$PP_DIR/build_solution.py")"
  PP_REQS="$(first_existing "$PP_DIR/requirements.txt")"
  PP_TEST="$(first_existing "$PP_DIR/06_test_agent.py" "$PP_DIR/test_agent.py")"
  if [ -n "$PP_ENTRY" ]; then
    PP_INPUT_PROMPTS="$(grep -c 'input(' "$PP_ENTRY" 2>/dev/null || echo 0)"
    # Surface the flags the entrypoint accepts (argparse add_argument long options).
    while IFS= read -r opt; do
      [ -n "$opt" ] || continue
      PP_ENTRY_ARGS="$(echo "$PP_ENTRY_ARGS" | jq --arg o "$opt" '. + [$o]')"
    done <<EOF
$(grep -oE 'add_argument\("(--[a-z-]+)"' "$PP_ENTRY" 2>/dev/null | sed -E 's/add_argument\("(--[a-z-]+)"/\1/' | sort -u)
EOF
  fi
fi

# ----------------------------------------------------------------------------
# Scenarios (scenarios.json, or --scenario examples in the guide)
#   Look in the post-provision dir AND the repo-standard data/scenarios/ location,
#   so the real scenario list is found rather than falling back to help-text examples.
# ----------------------------------------------------------------------------
SCEN_FILE="$(first_existing \
  "$PP_DIR/scenarios.json" \
  infra/scripts/post-provision/scenarios.json \
  data/scenarios/scenarios.json)"
SCENARIOS="[]"
if [ -n "$SCEN_FILE" ]; then
  SCENARIOS="$(jq -r 'if type=="object" then (.scenarios // .) else . end | keys_unsorted' "$SCEN_FILE" 2>/dev/null \
    || echo "[]")"
  [ -n "$SCENARIOS" ] || SCENARIOS="[]"
fi
if [ "$SCENARIOS" = "[]" ] && [ -n "$GUIDE" ]; then
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    SCENARIOS="$(echo "$SCENARIOS" | jq --arg s "$s" '. + [$s]')"
  done <<EOF
$(grep -oE -- '--scenario[= ]+[a-zA-Z0-9_-]+' "$GUIDE" 2>/dev/null | sed -E 's/--scenario[= ]+//' | sort -u)
EOF
fi

# ----------------------------------------------------------------------------
# CI-identity signals from the guide (OBO / user access token)
# ----------------------------------------------------------------------------
USES_OBO="false"; OBO_DOC=""
if [ -n "$GUIDE" ] && grep -qiE 'OBO|on-behalf-of|useUserAccessToken|User Access Token' -- "$GUIDE"; then
  USES_OBO="true"
fi
OBO_DOC="$(first_existing documents/SetupOBOAuthentication.md docs/SetupOBOAuthentication.md SetupOBOAuthentication.md)"

# ----------------------------------------------------------------------------
# Assemble JSON
# ----------------------------------------------------------------------------
jq -n \
  --arg repo_root "$REPO_ROOT" \
  --arg guide "$GUIDE" \
  --arg build_dir "$BUILD_DIR" \
  --argjson build_sh "$BUILD_SH" \
  --argjson build_ps1 "$BUILD_PS1" \
  --arg build_primary "$BUILD_PRIMARY" \
  --argjson build_rg_arg "$BUILD_RG_ARG" \
  --arg pp_dir "$PP_DIR" \
  --arg pp_entry "$PP_ENTRY" \
  --arg pp_reqs "$PP_REQS" \
  --arg pp_test "$PP_TEST" \
  --argjson pp_entry_args "$PP_ENTRY_ARGS" \
  --argjson pp_input_prompts "${PP_INPUT_PROMPTS:-0}" \
  --argjson scenarios "$SCENARIOS" \
  --argjson uses_obo "$USES_OBO" \
  --arg obo_doc "$OBO_DOC" \
  '{
    repo_root: $repo_root,
    deployment_guide: $guide,
    build: {
      dir: $build_dir,
      scripts_sh: $build_sh,
      scripts_ps1: $build_ps1,
      primary: $build_primary,
      supports_resource_group_arg: $build_rg_arg
    },
    post_provision: {
      dir: $pp_dir,
      entrypoint: $pp_entry,
      entrypoint_args: $pp_entry_args,
      requirements: $pp_reqs,
      interactive_input_calls: $pp_input_prompts,
      needs_stdin_feed: ($pp_input_prompts > 0)
    },
    scenarios: $scenarios,
    classification: {
      include: (
        ([$build_primary] | map(select(. != "")))
        + ([$pp_reqs] | map(select(. != "")))
        + ([$pp_entry] | map(select(. != "")))
      ),
      developer_only: (
        ([$pp_test] | map(select(. != "")))
      ),
      manual_post_steps: (
        if $uses_obo then
          [ (if $obo_doc != "" then "OBO auth: follow " + $obo_doc + " (only if useUserAccessToken=true; ~10 min)"
             else "OBO auth: configure On-Behalf-Of in the portal (only if useUserAccessToken=true; ~10 min)" end) ]
        else [] end
      )
    },
    ci_identity: {
      uses_user_access_token: $uses_obo,
      obo_doc: $obo_doc,
      note: "If useUserAccessToken defaults to true, set it to false in the per-env .bicepparam for unattended CI (values only, no Bicep edit)."
    }
  }'
