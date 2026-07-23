# START HERE — HongYi He

This repository publishes HongYi He's personal site from a **single folder** of a private
Obsidian vault. It is built with [Quartz v5](https://quartz.jzhao.xyz) and hosted for free
on GitHub Pages.

- **Live site:** https://hongyi42.github.io/blog
- **Repo:** https://github.com/hongyi42/blog
- **Source notes (private vault):** `~/Library/Mobile Documents/com~apple~CloudDocs/MyVault/Blog`
- **This project:** `~/GitHub/blog`

---

## The one rule

**Only notes inside `MyVault/Blog` are ever published.** Everything else in the vault stays
private and never leaves your machine. Publishing works by mirroring that one folder into this
project's `content/` directory.

---

## Everyday workflow: write → publish

1. Write or edit a note in Obsidian, saving it anywhere inside **`MyVault/Blog`**.
2. From this project folder, run:

   ```bash
   cd ~/GitHub/blog
   ./publish.sh
   ```

   (Optional custom message: `./publish.sh "Add note on volatility"`.)

3. That's it. `publish.sh` mirrors `MyVault/Blog` → `content/`, commits, and pushes to `main`.
   GitHub Actions builds the site and deploys it. The live site updates in ~1–2 minutes.

Watch a deploy finish with `gh run watch`, or check the repo's **Actions** tab.

---

## Hiding and deleting notes

- **Keep a note private even though it's in `Blog`:** add `draft: true` to its frontmatter.
  The `remove-draft` plugin drops it from the build.

  ```markdown
  ---
  title: "Work in progress"
  draft: true
  ---
  ```

- **Delete a note from the site:** remove it from `MyVault/Blog` and run `./publish.sh`.
  The mirror uses `rsync --delete`, so deleting locally also removes it from the live site.

---

## Preview locally before publishing (optional)

```bash
cd ~/GitHub/blog
# copy the latest notes in without committing:
rsync -av --delete "$HOME/Library/Mobile Documents/com~apple~CloudDocs/MyVault/Blog/" content/
# serve at http://localhost:8080
npx quartz build --serve --wsPort 3999
```

Open http://localhost:8080. The page hot-reloads as you edit files in `content/`.

> The `--wsPort 3999` avoids a clash on the default hot-reload port (3001), which was already
> in use on this machine. Plain `npx quartz build --serve` works too if 3001 is free.

---

## How it's wired

| Piece | What it does |
| --- | --- |
| `content/` | The published notes (a mirror of `MyVault/Blog`). Do not edit by hand — it's overwritten by `publish.sh`. |
| `quartz.config.yaml` | Site config: title, `baseUrl: hongyi42.github.io/blog`, plugins, theme. |
| `publish.sh` | Mirror + commit + push. Your everyday command. |
| `.github/workflows/deploy.yml` | On every push to `main`: `npm ci` → install plugins → `npx quartz build` → deploy to Pages. |
| `quartz/` | The Quartz framework. You rarely touch this. |

---

## Changing the site's look or behavior

Edit `quartz.config.yaml`, then rebuild (`npx quartz build --serve --wsPort 3999`) to preview.
Plugins live in the `plugins:` list, each with `enabled: true/false`. Full reference:
https://quartz.jzhao.xyz

After changing config, commit and push (`git add -A && git commit -m "..." && git push`) to deploy —
`publish.sh` only stages `content/`, so config changes need a manual commit.

---

## First-time setup checklist (already done)

- [x] Quartz v5 project created in `~/GitHub/blog`
- [x] `baseUrl` set to `hongyi42.github.io/blog`, title set to "Hongyi's Digital Garden"
- [x] `content/` seeded from `MyVault/Blog`
- [x] Public repo `hongyi42/blog` created and pushed to `main`
- [x] GitHub Pages source set to **GitHub Actions**
