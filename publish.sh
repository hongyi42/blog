#!/usr/bin/env bash
#
# publish.sh — deploy the digital garden.
#
# Mirrors the ONE published folder of the Obsidian vault (MyVault/Blog) into
# this project's content/ directory, commits, and pushes to `main`. GitHub
# Actions then builds the site and deploys it to GitHub Pages.
#
# Usage:
#   ./publish.sh                 # publish with an automatic commit message
#   ./publish.sh "Add note on X" # publish with a custom commit message
#
# Notes:
#   * Only notes inside MyVault/Blog are ever published. Everything else in the
#     vault stays private.
#   * To hide a note that lives in Blog, add `draft: true` to its frontmatter.
#   * rsync runs with --delete, so removing a note from MyVault/Blog also
#     removes it from the live site (this is intentional).
#
set -euo pipefail

VAULT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/MyVault"
BLOG_SRC="$VAULT/Blog"

# Resolve the project directory (where this script lives) regardless of cwd.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$PROJECT_DIR/content"

SITE_URL="https://hongyi42.github.io/blog"

if [ ! -d "$BLOG_SRC" ]; then
  echo "ERROR: published folder not found: $BLOG_SRC" >&2
  exit 1
fi

echo "==> Mirroring notes"
echo "    from: $BLOG_SRC"
echo "    to:   $CONTENT_DIR"
mkdir -p "$CONTENT_DIR"
rsync -av --delete \
  --exclude '.DS_Store' \
  --exclude '.obsidian/' \
  --exclude '.trash/' \
  "$BLOG_SRC/" "$CONTENT_DIR/"

cd "$PROJECT_DIR"

if [ -z "$(git status --porcelain content)" ]; then
  echo "==> No content changes to publish. Nothing to do."
  exit 0
fi

echo "==> Changes detected:"
git status --short content

git add -A content
MSG="${1:-Publish: update notes ($(date '+%Y-%m-%d %H:%M'))}"
git commit -m "$MSG"

echo "==> Pushing to origin/main"
git push origin main

echo ""
echo "==> Done. GitHub Actions is now building & deploying."
echo "    Watch it:  gh run watch   (or the repo's Actions tab)"
echo "    Live site: $SITE_URL"
