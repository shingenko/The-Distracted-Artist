#!/usr/bin/env bash
# ┌──────────────────────────────────────────────────┐
# │  new-post.sh — create a new comic post instantly │
# │  Usage: ./new-post.sh                            │
# └──────────────────────────────────────────────────┘
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POSTS_DIR="$SCRIPT_DIR/_posts"
IMAGES_DIR="$SCRIPT_DIR/assets/images/posts"

# ── colours ──
BOLD='\033[1m'
GRAY='\033[90m'
BLUE='\033[34m'
NC='\033[0m'

echo -e "${BOLD}ComicPages — New Post${NC}\n"

# ── 1. Title ──────────────────────────────────────
read -r -p "  Title: " TITLE
if [ -z "$TITLE" ]; then
  echo "  ✗ Title is required."
  exit 1
fi
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')

# ── 2. Date ───────────────────────────────────────
TODAY=$(date +%Y-%m-%d)
read -r -p "  Date [$TODAY]: " DATE
DATE=${DATE:-$TODAY}

# ── 3. Tags ───────────────────────────────────────
read -r -p "  Tags (comma-separated): " TAGS_RAW

# ── 4. Description / excerpt ─────────────────────
read -r -p "  Short description: " DESCRIPTION

# ── 5. Images directory ──────────────────────────
read -r -p "  Path to comic page images (blank to skip): " IMG_DIR

COMIC_PAGES=""
COVER_IMAGE=""
if [ -n "$IMG_DIR" ] && [ -d "$IMG_DIR" ]; then
  POST_IMG_DIR="$IMAGES_DIR/$SLUG"
  mkdir -p "$POST_IMG_DIR"

  echo -e "  ${GRAY}Copying images to $POST_IMG_DIR ...${NC}"
  cp "$IMG_DIR"/*.png "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.webp "$POST_IMG_DIR/" 2>/dev/null || true

  # Build the comic_pages frontmatter list
  PAGES=()
  for img in "$POST_IMG_DIR"/*; do
    [ -f "$img" ] || continue
    fname=$(basename "$img")
    PAGES+=("/assets/images/posts/$SLUG/$fname")
  done

  if [ ${#PAGES[@]} -gt 0 ]; then
    # Sort naturally
    IFS=$'\n' PAGES=($(sort <<<"${PAGES[*]}")); unset IFS
    COVER_IMAGE="${PAGES[0]}"
    COMIC_PAGES=$(printf '  - "%s"\n' "${PAGES[@]}")
  fi
fi

# ── 6. Commentary ────────────────────────────────
COMMENTARY=""
echo -e "  ${GRAY}Enter commentary (Ctrl+D when done):${NC}"
if read -r -d '' COMMENTARY < /dev/tty 2>/dev/null; then
  : # read succeeded
else
  COMMENTARY=""
fi

# ── 7. Write post ────────────────────────────────
FILENAME="$POSTS_DIR/$DATE-$SLUG.md"

TAGS_YAML=""
if [ -n "$TAGS_RAW" ]; then
  IFS=',' read -ra TARR <<< "$TAGS_RAW"
  for t in "${TARR[@]}"; do
    t_trimmed=$(echo "$t" | xargs)
    [ -n "$t_trimmed" ] && TAGS_YAML="$TAGS_YAML  - $t_trimmed"$'\n'
  done
fi

cat > "$FILENAME" << 'HEREDOC_HEADER'
---
layout: post
title: "TITLE_PLACEHOLDER"
date: DATE_PLACEHOLDER
description: "DESC_PLACEHOLDER"
HEREDOC_HEADER

# Replace placeholders (avoiding heredoc variable expansion issues)
sed -i "s|TITLE_PLACEHOLDER|$TITLE|" "$FILENAME"
sed -i "s|DATE_PLACEHOLDER|$DATE|" "$FILENAME"
sed -i "s|DESC_PLACEHOLDER|$DESCRIPTION|" "$FILENAME"

if [ -n "$TAGS_YAML" ]; then
  echo "tags:" >> "$FILENAME"
  printf '%s' "$TAGS_YAML" >> "$FILENAME"
fi

if [ -n "$COVER_IMAGE" ]; then
  echo "cover_image: \"$COVER_IMAGE\"" >> "$FILENAME"
fi

if [ -n "$COMIC_PAGES" ]; then
  echo "comic_pages:" >> "$FILENAME"
  printf '%s' "$COMIC_PAGES" >> "$FILENAME"
fi

cat >> "$FILENAME" << 'HEREDOC_FOOTER'
---
HEREDOC_FOOTER

if [ -n "$COMMENTARY" ]; then
  echo "" >> "$FILENAME"
  echo "$COMMENTARY" >> "$FILENAME"
fi

echo ""
echo -e "  ${BOLD}✓ Post created!${NC}"
echo -e "  ${GRAY}$FILENAME${NC}"
if [ -n "$IMG_DIR" ]; then
  echo -e "  ${GRAY}Images: $POST_IMG_DIR ($(ls "$POST_IMG_DIR" | wc -l) files)${NC}"
fi
echo ""
echo -e "  ${BLUE}Next:${NC} edit the post, then:"
echo -e "    git add . && git commit -m \"new post: $TITLE\" && git push"
