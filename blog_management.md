# Blog Management Guide

Everything you need to run your comic blog at [samueldraws.com](https://samueldraws.com).

---

## Quick Reference

| Task | Command |
|------|---------|
| New post | `./new-post.sh` |
| Edit post | `./edit-post.sh` |
| Delete post | `./delete-post.sh` |
| Deploy changes | `git add -A && git commit -m "message" && git push` |

---

## Creating a New Post

```bash
./new-post.sh
```

You'll be walked through each step:

1. **Title** — becomes the page title and URL slug (e.g. "Morning Coffee" → `/2025/06/15/morning-coffee/`)
2. **Date** — press Enter for today, or type `YYYY-MM-DD` to backdate
3. **Tags** — comma-separated, lowercase (e.g. `slice-of-life, quiet, city`)
4. **Short description** — one sentence; shows on cards and in search results
5. **Path to images** — folder on your computer with the comic pages (PNG, JPG, or WEBP). The script copies them into the right place. Leave blank if you want to add images later.
6. **Commentary** — paste your story text, then press Ctrl+D

After the script finishes, deploy:

```bash
git add -A
git commit -m "new post: Morning Coffee"
git push
```

Your post is live in ~30 seconds.

### Image Tips

- Name your files so they sort correctly: `page-01.png`, `page-02.png`, etc.
- The first image (alphabetically) becomes the cover on the homepage grid
- Images are stored in `assets/images/posts/<slug>/`
- Aspect ratio doesn't matter — the grid crops to 3:4 automatically

---

## Editing a Post

```bash
./edit-post.sh
```

Pick a post from the numbered list, then choose what to change:

### 1. Replace Images

Point to a folder with your new comic pages. The script clears the old images, copies the new ones in, and updates the frontmatter.

```
Path to new comic page images folder: /home/you/Drawings/coffee-final
```

### 2. Update Text / Commentary

Shows the first 10 lines of your current text, then lets you paste new commentary. Press Ctrl+D when done.

### 3. Update Tags

Comma-separated list. Replaces all existing tags.

### 4. Update Title

Changes the post title. Does NOT change the URL (the slug stays the same).

### 5. Update Description

Changes the short description shown on cards and in search results.

After editing, deploy:

```bash
git add -A
git commit -m "edit: morning-coffee"
git push
```

---

## Deleting a Post

```bash
./delete-post.sh
```

1. Pick a post from the numbered list
2. Type `DELETE` (all caps) to confirm
3. The post file and its image folder are removed

Any other text cancels the deletion. Deploy to take it off the live site:

```bash
git add -A
git commit -m "delete: old-post"
git push
```

---

## File Structure

```
_posts/                              # All posts live here
  └── 2025-06-12-first-light.md      #   YYYY-MM-DD-slug.md

assets/
  ├── css/style.css                  #   All styling
  ├── js/filter.js                   #   Tag filtering on homepage
  └── images/posts/                  #   Comic page images
      └── first-light/               #     One folder per post
          ├── page-01.png
          ├── page-02.png
          └── page-03.png

_layouts/                            # Page templates (don't touch)
_includes/                           # Reusable components (don't touch)
_config.yml                          # Site settings
```

---

## Post Frontmatter Reference

Each post in `_posts/` starts with YAML frontmatter between `---` markers. Here's the full format:

```yaml
---
layout: post
title: "First Light"
date: 2025-06-12
description: "A quiet morning in the city."
tags:
  - slice-of-life
  - quiet
cover_image: "/assets/images/posts/first-light/page-01.svg"
comic_pages:
  - "/assets/images/posts/first-light/page-01.svg"
  - "/assets/images/posts/first-light/page-02.svg"
  - "/assets/images/posts/first-light/page-03.svg"
---

Your commentary text goes here...
```

The scripts handle all of this for you, but you can also edit the markdown files directly.

---

## Site Pages

| Page | URL | What it is |
|------|-----|------------|
| Home | `/` | Grid of all posts with tag filter bar |
| Post | `/2025/06/12/first-light/` | Individual comic with viewer + comments |
| Archive | `/archive/` | All posts grouped by year → month |
| Tags | `/tags/` | Tag cloud with counts |

---

## Design Notes

- **Palette:** `#fafafa` background, white cards, `#7ea5ca` soft blue accents
- **Dark mode:** Automatic when your OS is in dark mode
- **Copyright:** Configurable in `_config.yml` → `copyright:` field
- **Comments:** Powered by Utterances (GitHub Issues). Anyone with a GitHub account can comment.

---

## Configuration

Key settings in `_config.yml`:

```yaml
title: The Distracted Artist    # Site name
copyright: Samuel Reyes         # Copyright holder
description: "Short comic..."   # SEO description
url: https://samueldraws.com    # Your domain
```

---

## Local Testing (Optional)

If you want to preview changes before pushing:

```bash
gem install bundler jekyll
cd ~/CodingProjects/ComicPages
mv Gemfile Gemfile.bak          # skip the github-pages gem locally
jekyll serve
# Open http://localhost:4000
# Restore Gemfile when done: mv Gemfile.bak Gemfile
```

---

## Troubleshooting

**Post isn't showing on the homepage?**  
Check that the date isn't in the future. Jekyll only publishes posts with dates ≤ today.

**Images look wrong?**  
Verify the paths in frontmatter start with `/assets/images/posts/`. The scripts handle this, but if you edit manually, watch for typos.

**Tag filtering not working?**  
Tags in the frontmatter must be a YAML list (each on its own line with `  - tagname`). No commas.

**Site not updating after push?**  
Give it 30 seconds. GitHub Pages rebuilds on every push. Check build status at:  
`https://github.com/shingenko/The-Distracted-Artist/deployments`
