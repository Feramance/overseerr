#!/bin/bash
set -e

FEATURE_BRANCH="feature-default-anime-instance-checkbox"

# Ensure we’re in a git repo
if [ ! -d .git ]; then
  echo "❌ Not a git repository. Run this script from inside your repo."
  exit 1
fi

# Add upstream if missing
if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "🔗 Adding upstream remote..."
  git remote add upstream https://github.com/sct/overseerr.git
fi

# Fetch latest from upstream and origin
echo "⬇️ Fetching latest changes..."
git fetch origin
git fetch upstream

# Checkout your feature branch
echo "🔄 Checking out your feature branch..."
git checkout $FEATURE_BRANCH || git checkout -b $FEATURE_BRANCH origin/$FEATURE_BRANCH

# Backup branch just in case
echo "💾 Creating backup branch..."
git branch backup-$FEATURE_BRANCH

echo ""
echo "=== OPTION 1: Rebase (cleaner history, preferred if this is your personal branch) ==="
echo "Running rebase..."
if git rebase upstream/develop; then
  echo "✅ Rebase successful."
  git push origin $FEATURE_BRANCH --force-with-lease
else
  echo "⚠️ Rebase conflicts detected!"
  echo "   Resolve conflicts, then run: git add . && git rebase --continue"
  echo "   Or abort with: git rebase --abort"
  exit 1
fi

echo ""
echo "=== OPTION 2: Merge (safer if multiple people are working on the branch) ==="
echo "If you prefer merge instead of rebase, run:"
echo "   git merge upstream/develop"
echo "   git push origin $FEATURE_BRANCH"
echo ""

echo "🎉 Done! Your feature branch is now updated from sct/develop."
