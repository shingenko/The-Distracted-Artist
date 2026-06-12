#!/usr/bin/env bash
# ┌──────────────────────────────────────────────────┐
# │  edit-post.sh — update an existing comic post    │
# │  Usage: ./edit-post.sh                           │
# └──────────────────────────────────────────────────┘
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POSTS_DIR="$SCRIPT_DIR/_posts"
IMAGES_DIR="$SCRIPT_DIR/assets/images/posts"

BOLD='\033[1m'
GRAY='\033[90m'
BLUE='\033[34m'
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BOLD}ComicPages — Edit Post${NC}\n"

# ── 1. List posts ────────────────────────────────
POSTS=()
while IFS= read -r -d '' f; do
  POSTS+=("$f")
done < <(find "$POSTS_DIR" -maxdepth 1 -name "*.md" -print0 | sort -r)

if [ ${#POSTS[@]} -eq 0 ]; then
  echo -e "  ${RED}No posts found.${NC}"
  exit 1
fi

echo -e "  ${GRAY}Posts:${NC}"
for i in "${!POSTS[@]}"; do
  fname=$(basename "${POSTS[$i]}")
  title=$(grep "^title:" "${POSTS[$i]}" | head -1 | sed 's/^title: *//' | tr -d '"' | xargs)
  echo -e "  ${BLUE}$((i+1))${NC}) $title  ${GRAY}($fname)${NC}"
done
echo ""

read -r -p "  Pick a post [1-${#POSTS[@]}]: " CHOICE
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#POSTS[@]}" ]; then
  echo -e "  ${RED}Invalid choice.${NC}"
  exit 1
fi

POST_FILE="${POSTS[$((CHOICE-1))]}"
SLUG=$(basename "$POST_FILE" .md | sed 's/^[0-9]*-[0-9]*-[0-9]*-//')
POST_IMG_DIR="$IMAGES_DIR/$SLUG"

echo ""
echo -e "  Editing: ${BOLD}$(grep "^title:" "$POST_FILE" | head -1 | sed 's/^title: *//' | tr -d '"')${NC}"
echo ""

# ── 2. What to edit ──────────────────────────────
echo -e "  ${GRAY}What would you like to update?${NC}"
echo "  1) Replace images (point to a folder of new images)"
echo "  2) Update text / commentary"
echo "  3) Update tags"
echo "  4) Update title"
echo "  5) Update description"
echo ""
read -r -p "  Choice [1-5]: " ACTION

case "$ACTION" in
  1)
    # ── Replace images ──────────────────────────
    read -r -p "  Path to new comic page images folder: " IMG_DIR
    if [ ! -d "$IMG_DIR" ]; then
      echo -e "  ${RED}Folder not found: $IMG_DIR${NC}"
      exit 1
    fi

    # Clear old images
    if [ -d "$POST_IMG_DIR" ]; then
      rm -rf "$POST_IMG_DIR"
    fi
    mkdir -p "$POST_IMG_DIR"

    echo -e "  ${GRAY}Copying images to $POST_IMG_DIR ...${NC}"
    cp "$IMG_DIR"/*.png "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.webp "$POST_IMG_DIR/" 2>/dev/null || true

    # Build new comic_pages + cover_image lines
    PAGES=()
    for img in "$POST_IMG_DIR"/*; do
      [ -f "$img" ] || continue
      fname=$(basename "$img")
      PAGES+=("/assets/images/posts/$SLUG/$fname")
    done

    if [ ${#PAGES[@]} -gt 0 ]; then
      IFS=$'\n' PAGES=($(sort <<<"${PAGES[*]}")); unset IFS
      COVER="${PAGES[0]}"

      # Remove old cover_image and comic_pages lines
      sed -i '/^cover_image:/d' "$POST_FILE"
      sed -i '/^comic_pages:/d' "$POST_FILE"
      sed -i '/^  - "\/assets\/images\/posts\//d' "$POST_FILE"

      # Insert new ones after the last frontmatter tag line
      # Find the line number of the closing ---
      CLOSE_LINE=$(grep -n "^---$" "$POST_FILE" | tail -1 | cut -d: -f1)
      # Insert before the closing ---
      INSERT_LINE=$((CLOSE_LINE - 1))

      # Build insert block
      INSERT="cover_image: \"$COVER\"\ncomic_pages:"
      for p in "${PAGES[@]}"; do
        INSERT="$INSERT\n  - \"$p\""
      done

      sed -i "${INSERT_LINE}a\\${INSERT}" "$POST_FILE" 2>/dev/null || {
        # If sed fails (special chars), use a simpler approach
        head -n "$INSERT_LINE" "$POST_FILE" > "$POST_FILE.tmp"
        echo "cover_image: \"$COVER\"" >> "$POST_FILE.tmp"
        echo "comic_pages:" >> "$POST_FILE.tmp"
        for p in "${PAGES[@]}"; do
          echo "  - \"$p\"" >> "$POST_FILE.tmp"
        done
        echo "---" >> "$POST_FILE.tmp"
        tail -n +$((CLOSE_LINE + 1)) "$POST_FILE" >> "$POST_FILE.tmp"
        mv "$POST_FILE.tmp" "$POST_FILE"
      }

      echo -e "  ${GREEN}✓ Updated ${#PAGES[@]} comic pages${NC}"
    fi
    ;;

  2)
    # ── Update text ─────────────────────────────
    # Find where the frontmatter ends
    BODY_START=$(grep -n "^---$" "$POST_FILE" | tail -1 | cut -d: -f1)
    BODY_START=$((BODY_START + 1))

    echo -e "  ${GRAY}Current text (first 10 lines):${NC}"
    head -n $((BODY_START + 10)) "$POST_FILE" | tail -n 10
    echo ""
    echo -e "  ${GRAY}Enter new commentary (Ctrl+D when done):${NC}"
    NEW_TEXT=""
    if read -r -d '' NEW_TEXT < /dev/tty 2>/dev/null; then
      : # got text
    else
      NEW_TEXT=""
    fi

    if [ -n "$NEW_TEXT" ]; then
      # Keep frontmatter, replace body
      head -n $((BODY_START - 1)) "$POST_FILE" > "$POST_FILE.tmp"
      echo "" >> "$POST_FILE.tmp"
      echo "$NEW_TEXT" >> "$POST_FILE.tmp"
      mv "$POST_FILE.tmp" "$POST_FILE"
      echo -e "  ${GREEN}✓ Text updated${NC}"
    fi
    ;;

  3)
    # ── Update tags ─────────────────────────────
    read -r -p "  New tags (comma-separated): " TAGS_RAW
    # Remove old tags
    sed -i '/^tags:/d' "$POST_FILE"
    sed -i '/^  - /d' "$POST_FILE"

    if [ -n "$TAGS_RAW" ]; then
      CLOSE_LINE=$(grep -n "^---$" "$POST_FILE" | tail -1 | cut -d: -f1)
      INSERT_LINE=$((CLOSE_LINE - 1))

      INSERT="tags:"
      IFS=',' read -ra TARR <<< "$TAGS_RAW"
      for t in "${TARR[@]}"; do
        t_trimmed=$(echo "$t" | xargs)
        [ -n "$t_trimmed" ] && INSERT="$INSERT\n  - $t_trimmed"
      done

      sed -i "${INSERT_LINE}a\\${INSERT}" "$POST_FILE" 2>/dev/null
      echo -e "  ${GREEN}✓ Tags updated${NC}"
    fi
    ;;

  4)
    # ── Update title ────────────────────────────
    CURRENT_TITLE=$(grep "^title:" "$POST_FILE" | head -1 | sed 's/^title: *//' | tr -d '"')
    read -r -p "  New title [$CURRENT_TITLE]: " NEW_TITLE
    if [ -n "$NEW_TITLE" ]; then
      sed -i "s/^title:.*/title: \"$NEW_TITLE\"/" "$POST_FILE"
      echo -e "  ${GREEN}✓ Title updated${NC}"
    fi
    ;;

  5)
    # ── Update description ──────────────────────
    CURRENT_DESC=$(grep "^description:" "$POST_FILE" | head -1 | sed 's/^description: *//' | tr -d '"')
    read -r -p "  New description [$CURRENT_DESC]: " NEW_DESC
    if [ -n "$NEW_DESC" ]; then
      sed -i "s/^description:.*/description: \"$NEW_DESC\"/" "$POST_FILE"
      echo -e "  ${GREEN}✓ Description updated${NC}"
    fi
    ;;

  *)
    echo -e "  ${RED}Invalid choice.${NC}"
    exit 1
    ;;
esac

echo ""
echo -e "  ${BOLD}Done!${NC}"
echo -e "  ${GRAY}git add . && git commit -m \"edit: $SLUG\" && git push${NC}"
