#!/bin/bash
# Auto-deploy: watches emilhvelplund.com files, commits & pushes changes to GitHub
# Runs as a background process.
# Usage: ./auto-deploy.sh

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit 1

# Ignore our own script and .git changes
fswatch -o --event Updated --event Created --event Removed \
  --exclude '.git/' \
  --exclude 'auto-deploy.sh' \
  "$DIR" |
while read -r _; do
  # Small delay to batch rapid edits
  sleep 2

  # Check if there's anything to commit
  if git status --porcelain | grep -q .; then
    echo "[$(date '+%H:%M:%S')] Changes detected — committing and pushing..."
    git add -A
    git commit -m "auto-deploy $(date '+%Y-%m-%d %H:%M')"
    git push origin main 2>&1
    echo "[$(date '+%H:%M:%S')] Deployed!"
  fi
done
