#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${MEA_ANALYSIS_DIR:-/MEA_Analysis}"
REPO_URL="${MEA_ANALYSIS_REPO_URL:-https://github.com/roybens/MEA_Analysis.git}"
BRANCH="${MEA_ANALYSIS_BRANCH:-main}"
AUTO_UPDATE="${MEA_ANALYSIS_AUTO_UPDATE:-1}"
AUTO_RUN="${MEA_ANALYSIS_AUTO_RUN:-1}"

# If the user is clearly requesting a shell, honor it.
if [[ "${1:-}" == "bash" || "${1:-}" == "/bin/bash" || "${1:-}" == "sh" || "${1:-}" == "/bin/sh" ]]; then
  exec "$@"
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "ERROR: MEA_Analysis repo not found at $REPO_DIR" >&2
  echo "This image expects the base to provide it, or you can rebuild the base." >&2
  exit 2
fi

if [[ "$AUTO_UPDATE" == "1" ]]; then
  echo "=== Updating MEA_Analysis before run ==="
  cd "$REPO_DIR"
  # Ensure origin points at the desired repo.
  git remote set-url origin "$REPO_URL" || true
  git fetch origin "$BRANCH" --depth=1 || true
  git reset --hard "origin/$BRANCH" || true

  echo "=== RUNNING PRE-PIPELINE HOOKS ==="
  if [[ -f "$REPO_DIR/dockers/spikesorter/docker_patches.sh" ]]; then
    echo "Executing docker patches..."
    chmod +x "$REPO_DIR/dockers/spikesorter/docker_patches.sh"
    bash "$REPO_DIR/dockers/spikesorter/docker_patches.sh"
  fi
fi

if [[ "$AUTO_RUN" == "1" ]]; then
  echo "=== Running pipeline ==="
  exec python3 "$REPO_DIR/IPNAnalysis/run_pipeline_driver.py" "$@"
fi

# Default: don't auto-run; behave like a normal container.
exec "$@"
