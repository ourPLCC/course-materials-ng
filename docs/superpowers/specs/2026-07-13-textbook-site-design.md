# Textbook Website Design

**Date:** 2026-07-13
**Status:** Approved
**Repo:** ourPLCC/course-materials-ng

## Goal

Set up this repository so authors can collaboratively write a textbook in
Markdown and publish it as a website via GitHub Pages, with versioned
releases instructors can pin their courses to.

## Context

- The textbook is written in `textbook/`, a top-level directory currently on
  the `textbook` feature branch (three chapters plus `style-guide.md`). That
  branch will be merged to main before infrastructure work begins.
- All other top-level directories (`Jackson/`, `JNotes/`, `Heliotis_Slides/`,
  `Assignments/`, `Misc/`) are reference materials authors draw from while
  writing. They stay in this repository for now: MkDocs only publishes its
  `docs_dir`, so they cost nothing, and same-repo keeps them one clone away
  while the textbook actively depends on them. If extraction is ever wanted,
  `git filter-repo` can split any directory out with full history.
- The related repository plcc-ng already publishes a Material for MkDocs site
  with mike and kroki; this design mirrors those conventions so maintainers
  move between the two repos without relearning anything.

## Architecture & repo layout

Single repository. `textbook/` is the sole source of the published site.

```
course-materials-ng/
├── mkdocs.yml              # site config, docs_dir: textbook
├── requirements.txt        # pinned: mkdocs-material, mike, kroki, autorefs
├── Makefile                # make install / serve / build
├── style-guide.md          # author-facing; moved out of textbook/
├── REUSE.toml              # annotates textbook/** as CC-BY-SA-4.0
├── LICENSES/
│   └── CC-BY-SA-4.0.txt
├── .github/workflows/
│   ├── checks.yml          # PR: strict build + link check
│   ├── deploy.yml          # push to main: mike deploy dev
│   └── release.yml         # manual: cut a named edition
├── textbook/               # the book (docs_dir)
│   ├── index.md            # landing page (new)
│   └── 00-introduction.md … 02-tokens.md
├── Jackson/ JNotes/ Heliotis_Slides/ Assignments/ Misc/   # reference, unpublished
├── README.md               # minimal (see Docs & licensing)
└── CONTRIBUTING.md         # rebuilt (see Docs & licensing)
```

The site publishes to `https://ourplcc.github.io/course-materials-ng/` from
the `gh-pages` branch (managed by mike). `style-guide.md` is for authors, not
readers, so it moves out of `textbook/` to the repo root.

## Site configuration (mkdocs.yml)

Mirrors plcc-ng with the deltas this repo needs:

- **Theme:** Material, same feature set and light/dark palette toggle as
  plcc-ng (navigation tabs/sections, integrated TOC, search suggest, content
  tabs).
- **Plugins:**
  - `search`
  - `mike` — versioning (see Publishing & versioning)
  - `kroki` — renders PlantUML fenced code blocks into SVGs at build time.
    Requires network access to kroki.io during builds; same trade-off plcc-ng
    already accepted.
  - `autorefs` — authors give headings stable ids
    (`## Environments {#environments}`) and link by id from anywhere
    (`[environments][]`). Links survive file moves and renames; only changing
    the id itself requires a search-and-replace. "Link by anchor id, not by
    path" becomes a style-guide rule.
- **Nav:** explicit `nav:` listing chapters in order; hand-maintained.
- **Strict builds:** `mkdocs build --strict` fails on broken internal links,
  missing nav entries, and orphaned pages. CI and `make build` both use it.
- **Footer:** `copyright` shows the CC-BY-SA-4.0 notice linking to the
  license.
- `site_url`, `repo_url`, and `extra.version.provider: mike` set for this
  repo.
- mkdocs-redirects is deliberately deferred until the site has readers with
  bookmarks worth preserving.

## Publishing & versioning (mike)

- **deploy.yml** — on push to main: build and `mike deploy --push dev`,
  publishing the current draft as the `dev` version on `gh-pages`.
- **release.yml** — `workflow_dispatch` with a version input. Cuts a named
  edition: `mike deploy --push --update-aliases <edition> latest`
  (e.g., `2026.09`). `latest` becomes the default version readers land on
  once the first edition exists; until then `dev` is the default.
- Material's version selector lets readers switch between `dev` and named
  editions.
- GitHub Pages serves the `gh-pages` branch; mike stores each version in its
  own subdirectory.

## CI quality gates (checks.yml, on PRs)

- `mkdocs build --strict` — the hard gate; fails on internal breakage.
- lychee (or similar) external link check over `textbook/` — a separate,
  visible but non-required check, since external sites flake.

## Author experience

- **Setup:** `requirements.txt` with pinned versions. Makefile targets:
  `make install` (venv + pip install), `make serve` (live preview at
  localhost:8000), `make build` (strict build, identical to CI).
- **Workflow:** short-lived branches and PRs (forks only for contributors
  without write access). CI runs the checks; merge to main auto-publishes
  `dev`.

## Docs & licensing

**README.md** — minimal: one-paragraph description, link to the published
textbook site, link to CONTRIBUTING.md, and a licensing note stating
`textbook/` content is CC-BY-SA-4.0 International while other directories
carry their own licenses (the existing GPL-3.0 root LICENSE and Jackson's
GFDL annotations remain as-is for their content).

**CONTRIBUTING.md** — rebuilt with a textbook section covering:

- Suggested workflow: short-lived branches + PRs; forks only if necessary.
- Development environment and tools: Python venv via `make install`,
  `make serve` to preview, `make build` to run the same strict check as CI.
- Linking mechanism: link by anchor id (mkdocs-autorefs), not by file path.
- Pointer to `style-guide.md` for writing conventions.
- How releases are cut: merges to main auto-publish `dev`; named editions
  are cut via the manual release workflow.

**Licensing mechanics** — REUSE convention (already used in `Jackson/` and
plcc-ng): add `LICENSES/CC-BY-SA-4.0.txt` and a root `REUSE.toml` annotating
`textbook/**` as `CC-BY-SA-4.0`.

## Work items

Each item is a separate work-cycle (branch + PR):

1. **Merge `textbook` branch to main.** Blocked on the branch author's
   go-ahead; everything else builds on it. Fallback if the merge stalls:
   build infrastructure on main pointing at `textbook/`, which lands when
   the branch merges.
2. **MkDocs scaffolding.** `mkdocs.yml`, `requirements.txt`, `Makefile`,
   `textbook/index.md`, move `style-guide.md` to repo root. Verify
   `make serve` renders the chapters with PlantUML diagrams.
3. **CI checks.** `checks.yml`: strict build (required) + lychee link check
   (visible, non-required).
4. **Deploy pipeline.** `deploy.yml` (mike `dev` on merge to main), enable
   GitHub Pages on `gh-pages`, `release.yml` for cutting editions, verify
   the live site.
5. **README + CONTRIBUTING rebuild, licensing.** Minimal README, textbook
   contributor guide, CC-BY-SA-4.0 via REUSE as described above.

Items 2–5 are sequential (each builds on the previous), though 5 can overlap
with 3–4.

## Error handling & testing

- Strict builds are the primary correctness check for content: broken links,
  bad nav, orphaned pages fail PRs before merge.
- `make build` gives authors the identical check locally.
- Deploy failures surface as failed Actions runs on main; the previously
  deployed versions on `gh-pages` remain live (mike deploys are per-version,
  so a failed `dev` deploy can't damage released editions).
- External link rot surfaces in the non-required lychee check without
  blocking authors.
