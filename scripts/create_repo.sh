#!/usr/bin/env bash
set -e

APP_NAME="aithespire"
DESCRIPTION="AIthespire — Private, offline AI chat powered by Ollama. No cloud. No tracking."

# 1. Initialise git if not already done
if [ ! -d .git ]; then
  git init
fi

git add .
git commit -m "chore: initial project scaffold" || true

# 2. Create public repo on GitHub (requires `gh` CLI to be authenticated)
gh repo create "$APP_NAME" \
  --public \
  --description "$DESCRIPTION" \
  --source=. \
  --remote=origin \
  --push

# 3. Set default branch
gh repo edit "$APP_NAME" --default-branch main

echo "✅ Repository created: https://github.com/$(gh api user --jq .login)/$APP_NAME"
