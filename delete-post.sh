#!/usr/bin/env bash
# ┌──────────────────────────────────────────────────┐
# │  delete-post.sh — remove a comic post            │
# │  Usage: ./delete-post.sh                         │
# └──────────────────────────────────────────────────┘
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POSTS_DIR="$SCRIPT_DIR/_posts"
IMAGES_DIR="$SCRIPT_DIR/assets/images/posts"

BOLD='\033[1m'
GRAY='\033[90m'
BLUE='\033[34m'
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m'

echo -e "${BOLD}ComicPages — Delete Post${NC}\n"

# ── 1. List posts ────────────────────────────────
POSTS=()
while IFS= read -r -d '' f; do
  POSTS+=("$f")
done < <(find "$POSTS_DIR" -maxdepth 1 -name "*.md" -print0 | sort -r)

if [ ${#POSTS[@]} -eq 0 ]; then
  echo -e "  ${RED}No posts to delete.${NC}"
  exit 1
fi

echo -e "  ${GRAY}Posts:${NC}"
for i in "${!POSTS[@]}"; do
  fname=$(basename "${POSTS[$i]}")
  title=$(grep "^title:" "${POSTS[$i]}" | head -1 | sed 's/^title: *//' | tr -d '"' | xargs)
  echo -e "  ${RED}$((i+1))${NC}) $title  ${GRAY}($fname)${NC}"
done
echo ""

read -r -p "  Pick a post to delete [1-${#POSTS[@]}]: " CHOICE
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#POSTS[@]}" ]; then
  echo -e "  ${RED}Invalid choice.${NC}"
  exit 1
fi

POST_FILE="${POSTS[$((CHOICE-1))]}"
SLUG=$(basename "$POST_FILE" .md | sed 's/^[0-9]*-[0-9]*-[0-9]*-//')
POST_IMG_DIR="$IMAGES_DIR/$SLUG"
TITLE=$(grep "^title:" "$POST_FILE" | head -1 | sed 's/^title: *//' | tr -d '"')

echo ""
echo -e "  ${BOLD}Delete:${NC} $TITLE"
echo -e "  ${GRAY}File:${NC} $POST_FILE"
if [ -d "$POST_IMG_DIR" ]; then
  echo -e "  ${GRAY}Images:${NC} $POST_IMG_DIR ($(ls "$POST_IMG_DIR" | wc -l) files)"
fi
echo ""

read -r -p "  Are you sure? Type DELETE to confirm: " CONFIRM
if [ "$CONFIRM" != "DELETE" ]; then
  echo -e "  ${GRAY}Cancelled.${NC}"
  exit 0
fi

rm "$POST_FILE"
if [ -d "$POST_IMG_DIR" ]; then
  rm -rf "$POST_IMG_DIR"
fi

echo ""
echo -e "  ${GREEN}✓ Deleted:${NC} $TITLE"
echo -e "  ${GRAY}git add -A && git commit -m \"delete: $SLUG\" && git push${NC}"
