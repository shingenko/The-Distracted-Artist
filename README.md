# ComicPages

A minimal, beautiful GitHub Pages blog for sharing short comic stories (3–6 pages each).

**Features:**
- Grid layout with per-post cover images
- Tag filtering (click a tag to filter in-place)
- Archive page grouped by year & month
- Individual post pages with full comic viewer
- Dark mode support (automatic via `prefers-color-scheme`)
- Soft gray/white palette with whisper-of-blue accents
- Zero build step — just push markdown + images

## Creating a New Post

```bash
./new-post.sh
```

You'll be prompted for:

1. **Title** — becomes the page title and URL slug
2. **Date** — defaults to today
3. **Tags** — comma-separated (e.g. `slice-of-life, sci-fi`)
4. **Description** — short excerpt for cards and SEO
5. **Path to images** — folder containing your comic pages (PNG/JPG/WEBP)
6. **Commentary** — your written commentary (paste and press Ctrl+D)

The script copies your images into `assets/images/posts/<slug>/`, generates
the post file with proper frontmatter, and you're done.

## File Structure

```
_posts/                           # Your comic posts (YYYY-MM-DD-slug.md)
assets/images/posts/<slug>/      # Comic page images per post
assets/css/style.css             # All styling
assets/js/filter.js              # Tag filtering
_layouts/                        # Page templates
_includes/                       # Reusable components (header, footer)
```

## Local Development (optional)

```bash
gem install bundler
bundle install
bundle exec jekyll serve
```

Open `http://localhost:4000/ComicPages/`

## Deploying

1. Create a GitHub repo named `ComicPages`
2. Push: `git remote add origin git@github.com:YOU/ComicPages.git && git push -u origin main`
3. Enable GitHub Pages in repo Settings → Pages → Source: `main` branch
4. Your site will be live at `https://YOU.github.io/ComicPages/`

## Design

- **Background:** `#fafafa` (near-white)
- **Cards:** `#ffffff` with subtle shadows
- **Accent:** `#7ea5ca` (soft blue) — used only for links, active states, tag pills
- **Text:** `#333` / `#777` grays
- **Typography:** System font stack for fast loading
- **Dark mode:** Automatic when your OS is in dark mode
