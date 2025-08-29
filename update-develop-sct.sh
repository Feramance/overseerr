#!/bin/bash

# Smart update of feature branch from upstream develop
# Only prompts for conflicts on files modified in the feature branch
# Fork URL: https://github.com/Feramance/overseerr.git
# Upstream URL: https://github.com/sct/overseerr.git
# Feature branch: feature-default-anime-instance-checkbox

set -e

FORK_REMOTE="origin"
UPSTREAM_REMOTE="upstream"
FEATURE_BRANCH="feature-default-anime-instance-checkbox"
BACKUP_BRANCH="backup-${FEATURE_BRANCH}"

# 1️⃣ Ensure remotes exist
git remote | grep -q "$UPSTREAM_REMOTE" || git remote add $UPSTREAM_REMOTE https://github.com/sct/overseerr.git
git remote | grep -q "$FORK_REMOTE" || git remote add $FORK_REMOTE https://github.com/Feramance/overseerr.git

echo "⬇️ Fetching latest changes..."
git fetch $FORK_REMOTE
git fetch $UPSTREAM_REMOTE

# 2️⃣ Checkout feature branch
git checkout $FEATURE_BRANCH

# 3️⃣ Backup branch
if git show-ref --verify --quiet refs/heads/$BACKUP_BRANCH; then
    echo "⚠️ Backup branch $BACKUP_BRANCH already exists. Skipping backup creation."
else
    echo "💾 Creating backup branch $BACKUP_BRANCH..."
    git checkout -b $BACKUP_BRANCH
    git checkout $FEATURE_BRANCH
fi

# 4️⃣ Identify files changed in feature branch vs upstream develop
echo "🔍 Determining files changed in feature branch..."
CHANGED_FILES=$(git diff --name-only $UPSTREAM_REMOTE/develop..$FEATURE_BRANCH)

# 5️⃣ Merge with 'ours' for files not changed in feature branch
echo "🔧 Merging upstream develop smartly..."
git merge --no-commit $UPSTREAM_REMOTE/develop || true

# Auto-resolve files not modified in feature branch
for file in $(git diff --name-only --diff-filter=U); do
    if ! echo "$CHANGED_FILES" | grep -q "^$file$"; then
        echo "Auto-resolving $file (unchanged in feature branch)..."
        git checkout --ours "$file"
        git add "$file"
    fi
done

# Commit merge (manual resolution needed only for true conflicts)
if git diff --check | grep -q '^'; then
    echo "⚠️ Merge has conflicts in files you modified. Resolve them manually:"
    echo "   1. git status"
    echo "   2. edit conflicted files"
    echo "   3. git add <resolved_files>"
    echo "   4. git commit"
    exit 1
else
    git commit -m "Merge upstream develop into $FEATURE_BRANCH (smart merge, auto-resolved unmodified files)"
fi

# 6️⃣ Push updated branch
echo "📤 Pushing updated branch to your fork..."
git push $FORK_REMOTE $FEATURE_BRANCH

echo "🎉 Feature branch updated with upstream develop!"
