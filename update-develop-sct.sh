#!/bin/bash

# Auto-update feature branch from upstream develop
# Fork URL: https://github.com/Feramance/overseerr.git
# Upstream URL: https://github.com/sct/overseerr.git
# Feature branch: feature-default-anime-instance-checkbox

set -e  # Exit on any error

FORK_REMOTE="origin"
UPSTREAM_REMOTE="upstream"
FEATURE_BRANCH="feature-default-anime-instance-checkbox"
BACKUP_BRANCH="backup-${FEATURE_BRANCH}"

# 1️⃣ Ensure remotes are set
git remote | grep -q "$UPSTREAM_REMOTE" || git remote add $UPSTREAM_REMOTE https://github.com/sct/overseerr.git
git remote | grep -q "$FORK_REMOTE" || git remote add $FORK_REMOTE https://github.com/Feramance/overseerr.git

echo "⬇️ Fetching latest changes from all remotes..."
git fetch $FORK_REMOTE
git fetch $UPSTREAM_REMOTE

# 2️⃣ Checkout feature branch
git checkout $FEATURE_BRANCH

# 3️⃣ Create backup branch if it doesn't exist
if git show-ref --verify --quiet refs/heads/$BACKUP_BRANCH; then
    echo "⚠️ Backup branch $BACKUP_BRANCH already exists. Skipping backup creation."
else
    echo "💾 Creating backup branch $BACKUP_BRANCH..."
    git checkout -b $BACKUP_BRANCH
    git checkout $FEATURE_BRANCH
fi

# 4️⃣ Merge upstream develop into feature branch
echo "🔧 Merging changes from upstream develop into $FEATURE_BRANCH..."
git merge $UPSTREAM_REMOTE/develop --no-ff -m "Merge upstream develop into $FEATURE_BRANCH"

# 5️⃣ Detect conflicts
if ! git diff --check | grep -q '^'; then
    echo "✅ Merge completed without conflicts."
else
    echo "⚠️ Merge has conflicts! Resolve them manually, then commit."
    echo "   After resolving, run: git commit (if needed) and then git push $FORK_REMOTE $FEATURE_BRANCH"
    exit 1
fi

# 6️⃣ Push updated feature branch to your fork
echo "📤 Pushing updated $FEATURE_BRANCH to your fork..."
git push $FORK_REMOTE $FEATURE_BRANCH

echo "🎉 Feature branch is now updated with upstream develop!"
