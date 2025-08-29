#!/bin/bash

# Auto-rebase feature branch from upstream develop
# Fork URL: https://github.com/Feramance/overseerr.git
# Upstream URL: https://github.com/sct/overseerr.git
# Feature branch: feature-default-anime-instance-checkbox

set -e

FORK_REMOTE="origin"
UPSTREAM_REMOTE="upstream"
FEATURE_BRANCH="feature-default-anime-instance-checkbox"
BACKUP_BRANCH="backup-${FEATURE_BRANCH}"

# 1️⃣ Ensure remotes are set
git remote | grep -q "$UPSTREAM_REMOTE" || git remote add $UPSTREAM_REMOTE https://github.com/sct/overseerr.git
git remote | grep -q "$FORK_REMOTE" || git remote add $FORK_REMOTE https://github.com/Feramance/overseerr.git

echo "⬇️ Fetching latest changes..."
git fetch $FORK_REMOTE
git fetch $UPSTREAM_REMOTE

# 2️⃣ Checkout feature branch
git checkout $FEATURE_BRANCH

# 3️⃣ Create backup branch if not exists
if git show-ref --verify --quiet refs/heads/$BACKUP_BRANCH; then
    echo "⚠️ Backup branch $BACKUP_BRANCH already exists. Skipping backup creation."
else
    echo "💾 Creating backup branch $BACKUP_BRANCH..."
    git checkout -b $BACKUP_BRANCH
    git checkout $FEATURE_BRANCH
fi

# 4️⃣ Rebase feature branch onto upstream develop
echo "🔧 Rebasing $FEATURE_BRANCH onto upstream/develop..."
if git rebase $UPSTREAM_REMOTE/develop; then
    echo "✅ Rebase completed successfully."
else
    echo "⚠️ Rebase encountered conflicts! Resolve them manually:"
    echo "   1. git status"
    echo "   2. edit conflicted files"
    echo "   3. git add <resolved_files>"
    echo "   4. git rebase --continue"
    exit 1
fi

# 5️⃣ Push updated branch to your fork (force required for rebase)
echo "📤 Pushing updated branch to your fork..."
git push -f $FORK_REMOTE $FEATURE_BRANCH

echo "🎉 Feature branch successfully rebased with upstream develop!"
