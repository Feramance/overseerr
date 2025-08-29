#!/bin/bash

# Smart update + PR creation
# Fork URL: https://github.com/Feramance/overseerr.git
# Upstream URL: https://github.com/sct/overseerr.git
# Feature branch: feature-default-anime-instance-checkbox

set -e

FORK_REMOTE="origin"
UPSTREAM_REMOTE="upstream"
FEATURE_BRANCH="feature-default-anime-instance-checkbox"
BACKUP_BRANCH="backup-${FEATURE_BRANCH}"
PR_TITLE="Update $FEATURE_BRANCH with upstream develop"
PR_BODY="This PR merges changes from upstream develop into $FEATURE_BRANCH using smart merge."

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI 'gh' is not installed. Install it to create PRs automatically."
    exit 1
fi

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

# 4️⃣ Smart merge
echo "🔧 Merging upstream develop smartly..."
git merge --no-commit $UPSTREAM_REMOTE/develop || true

# Identify files changed in feature branch
CHANGED_FILES=$(git diff --name-only $UPSTREAM_REMOTE/develop..$FEATURE_BRANCH)

# Auto-resolve files not modified in feature branch
for file in $(git diff --name-only --diff-filter=U); do
    if ! echo "$CHANGED_FILES" | grep -q "^$file$"; then
        echo "Auto-resolving $file (unchanged in feature branch)..."
        git checkout --ours "$file"
        git add "$file"
    fi
done

# Commit merge
if git diff --check | grep -q '^'; then
    echo "⚠️ Merge has conflicts in files you modified. Resolve them manually and commit."
    exit 1
else
    git commit -m "Merge upstream develop into $FEATURE_BRANCH (smart merge)"
fi

# 5️⃣ Push updated branch
git push $FORK_REMOTE $FEATURE_BRANCH

# 6️⃣ Create Pull Request using GitHub CLI
echo "📤 Creating Pull Request..."
gh pr create \
    --repo "Feramance/overseerr" \
    --head "$FEATURE_BRANCH" \
    --base "$FEATURE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY"

echo "🎉 Pull Request created successfully!"
