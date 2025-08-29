#!/bin/bash
set -e

# Ensure we’re in a git repo
if [ ! -d .git ]; then
  echo "❌ Not a git repository. Run this script from inside your repo."
  exit 1
fi

# Switch to develop branch
echo "🔄 Checking out develop branch..."
git checkout develop || git checkout -b develop

# Add upstream if not already set
if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "🔗 Adding upstream remote..."
  git remote add upstream https://github.com/sct/overseerr.git   # <-- replace with correct upstream repo URL
else
  echo "✅ Upstream already set: $(git remote get-url upstream)"
fi

# Show origin to confirm it's your fork
echo "📌 Origin remote is: $(git remote get-url origin)"

# Fetch latest from upstream
echo "⬇️ Fetching upstream..."
git fetch upstream

# Force reset local develop to match upstream/develop
echo "⚠️ WARNING: This will overwrite local changes on 'develop'."
git reset --hard upstream/develop

# Push to your fork (origin)
echo "⬆️ Force pushing to your fork (origin/develop)..."
git push origin develop --force

echo "🎉 Done! Your fork (Feramance/overseerr) develop branch is now identical to sct/overseerr develop."
