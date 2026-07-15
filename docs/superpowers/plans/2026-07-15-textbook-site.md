# Textbook Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the `textbook/` directory as a versioned Material for MkDocs site on GitHub Pages, with CI quality gates, a mike-based release process, and contributor docs.

**Architecture:** Single repo; `textbook/` is the MkDocs `docs_dir` and sole published content. mike manages versions (`dev` on every merge to main; named editions like `2026.09` cut manually) on the `gh-pages` branch. Conventions mirror the plcc-ng repo.

**Tech Stack:** MkDocs + mkdocs-material, mike, mkdocs-kroki-plugin (PlantUML via kroki.io), mkdocs-autorefs, GitHub Actions, lychee, REUSE.

**Spec:** `docs/superpowers/specs/2026-07-13-textbook-site-design.md`

## Global Constraints

- Every task is its own work-cycle: branch off up-to-date `main`, PR to `main`, merge before the next task starts. Tasks are sequential (Task 5 may overlap Tasks 3–4).
- All builds use `mkdocs build --strict` — locally (`make build`) and in CI. A non-strict build is never the check.
- Dependencies are pinned exactly in `requirements.txt` (`==`, no ranges).
- Site URL: `https://ourplcc.github.io/course-materials-ng/`. Repo: `https://github.com/ourPLCC/course-materials-ng`.
- `textbook/**` content license is `CC-BY-SA-4.0` (REUSE convention). Root `LICENSE` (GPL-3.0) and `Jackson/` annotations stay untouched.
- Cross-references link by anchor id (mkdocs-autorefs `[text][id]` syntax + `attr_list` explicit ids), never by file path.
- mkdocs-redirects is deliberately **not** installed (deferred per spec).
- PRs are created and merged by the maintainer (the human), not by implementers. Task work ends at local commits on the task branch; do not run `git push` or `gh pr create`.

---

### Task 1: Merge `textbook` branch to main — ✅ ALREADY COMPLETE

Work item 1. **Done before plan execution began** (verified 2026-07-15): the `textbook` branch was merged to main on GitHub and its remote branch deleted. `main` now contains `textbook/00-introduction.md`, `01-overview.md`, `02-tokens.md`, `03-syntax.md` (a fourth chapter added after the spec was written), and `textbook/style-guide.md`. No action needed; later tasks build on this.

---

### Task 2: MkDocs scaffolding

Work item 2. Branch: `mkdocs-scaffolding`. After this task, `make install && make build` produces a strict-clean site rendering all three chapters with PlantUML diagrams.

**Files:**
- Create: `mkdocs.yml`
- Create: `requirements.txt`
- Create: `Makefile`
- Create: `textbook/index.md`
- Move: `textbook/style-guide.md` → `style-guide.md` (repo root); append linking rule

**Interfaces:**
- Produces: `make install` / `make serve` / `make build` targets; `mkdocs.yml` with `docs_dir: textbook`, plugins `search, mike, kroki, autorefs`, extension `attr_list`. Tasks 3–4 reuse `pip install -r requirements.txt` + `mkdocs build --strict` exactly as defined here.

- [ ] **Step 1: Branch**

```bash
git checkout main && git pull && git checkout -b mkdocs-scaffolding
```

- [ ] **Step 2: Write `requirements.txt`**

```
mkdocs-material==9.6.15
mike==2.1.3
mkdocs-kroki-plugin==1.6.0
mkdocs-autorefs==1.4.2
```

Note: these were the latest known pins at plan time. If `pip install` in Step 6 reports a pin unavailable, replace with the latest release (`pip index versions <package>`) and keep it exact (`==`).

- [ ] **Step 3: Write `mkdocs.yml`**

Mirrors plcc-ng's config (theme features, palette toggle, kroki settings, mike provider) with this repo's deltas: `docs_dir`, autorefs, `attr_list`, CC footer.

```yaml
site_name: Programming Languages with PLCC
site_url: https://ourplcc.github.io/course-materials-ng/
repo_url: https://github.com/ourPLCC/course-materials-ng
repo_name: ourPLCC/course-materials-ng
docs_dir: textbook

copyright: >
  Textbook content licensed under
  <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a>.

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - search.suggest
    - content.tabs
    - content.tabs.link
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      toggle:
        icon: material/weather-night
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      toggle:
        icon: material/weather-sunny
        name: Switch to light mode

plugins:
  - search
  - mike
  - kroki:
      fence_prefix: ''
      tag_format: svg
  - autorefs

nav:
  - Home: index.md
  - Introduction: 00-introduction.md
  - Overview: 01-overview.md
  - Tokens: 02-tokens.md
  - Syntax: 03-syntax.md

extra:
  version:
    provider: mike

markdown_extensions:
  - attr_list
  - pymdownx.superfences
```

(`site_name` is a placeholder the authors can rename; nothing else depends on it.)

- [ ] **Step 4: Write `Makefile`**

```make
VENV = .venv
PIP = $(VENV)/bin/pip
MKDOCS = $(VENV)/bin/mkdocs

.PHONY: install serve build clean

install:
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.txt

serve:
	$(MKDOCS) serve

build:
	$(MKDOCS) build --strict

clean:
	rm -rf $(VENV) site
```

- [ ] **Step 5: Landing page, style-guide move, .gitignore**

Write `textbook/index.md`:

```markdown
# Programming Languages with PLCC {#home}

A textbook for an upper-level programming languages course built around
[PLCC](https://github.com/ourPLCC/plcc), a Programming Languages Compiler
Compiler. We study languages by building interpreters for them.

Use the version selector in the header to switch between the in-progress
`dev` version and named editions your course may pin to.

Start with the [Introduction](00-introduction.md).
```

Move the style guide and add the linking rule (spec: "Link by anchor id, not by path" becomes a style-guide rule):

```bash
git mv textbook/style-guide.md style-guide.md
cat >> style-guide.md <<'EOF'
- Give every heading you link to an explicit id (`## Environments {#environments}`)
  and link to it by id (`[environments][]` or `[text][environments]`), never by
  file path. Ids survive file moves and renames.
EOF
```

(`.gitignore` needs no changes: the existing root `.gitignore` already ignores `.venv` and `/site`.)

- [ ] **Step 6: Verify — install and strict build**

```bash
make install
make build
```

Expected: both succeed; strict build reports no warnings. (Kroki needs network access to kroki.io.)

- [ ] **Step 7: Verify — PlantUML rendered and pages present**

```bash
grep -c '<svg' site/01-overview/index.html
ls site/00-introduction/index.html site/02-tokens/index.html site/03-syntax/index.html site/index.html
```

Expected: svg count ≥ 3 (the overview chapter has three PlantUML fences; 03-syntax has none); all five pages exist. Optionally `make serve` and eyeball http://localhost:8000.

- [ ] **Step 8: Commit**

```bash
git add mkdocs.yml requirements.txt Makefile textbook/index.md style-guide.md
git commit -m "feat: add MkDocs scaffolding for textbook site"
```

The maintainer pushes/opens/merges the PR; later tasks branch from the merged result.

---

### Task 3: CI checks

Work item 3. Branch: `ci-checks`. PRs get a required strict build and a visible-but-non-required external link check. The PR that adds this workflow also exercises it (pull_request workflows run from the PR's own branch).

**Files:**
- Create: `.github/workflows/checks.yml`

**Interfaces:**
- Consumes: `requirements.txt` and strict build from Task 2.
- Produces: check names `Strict build` (to be marked required) and `External links` (never required).

- [ ] **Step 1: Branch**

```bash
git checkout main && git pull && git checkout -b ci-checks
```

- [ ] **Step 2: Write `.github/workflows/checks.yml`**

```yaml
name: Checks

on:
  pull_request:

jobs:
  build:
    name: Strict build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: mkdocs build --strict

  links:
    name: External links
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check external links
        uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress 'textbook/**/*.md'
          fail: true
```

`External links` may go red on flaky external sites — that is by design; it is visible but must never be added to required status checks.

- [ ] **Step 3: Commit, PR, and verify the checks run**

```bash
git add .github/workflows/checks.yml
git commit -m "ci: add strict-build and link checks for PRs"
git push -u origin ci-checks
gh pr create --base main --title "ci: PR checks (strict build + link check)" \
  --body "Work item 3 of docs/superpowers/specs/2026-07-13-textbook-site-design.md."
gh pr checks --watch
```

Expected: `Strict build` passes on this very PR. `External links` passes or fails on external flakiness only (inspect its log if red — broken real links in `textbook/` should be fixed in this PR).

- [ ] **Step 4: Mark `Strict build` required (human/maintainer, web UI or API)**

Repo Settings → Branches → protection rule for `main` → require status check `Strict build`. Do **not** require `External links`. Merge the PR.

---

### Task 4: Deploy pipeline

Work item 4. Branch: `deploy-pipeline`. Merges to main auto-publish `dev`; a manual workflow cuts named editions; GitHub Pages serves `gh-pages`.

**Files:**
- Create: `.github/workflows/deploy.yml`
- Create: `.github/workflows/release.yml`

**Interfaces:**
- Consumes: `requirements.txt`, `mkdocs.yml` (`extra.version.provider: mike`) from Task 2.
- Produces: `gh-pages` branch (mike-managed); versions `dev` (default until first edition) and, per release run, `<edition>` + `latest` alias (default thereafter). Live site at https://ourplcc.github.io/course-materials-ng/.

- [ ] **Step 1: Branch**

```bash
git checkout main && git pull && git checkout -b deploy-pipeline
```

- [ ] **Step 2: Write `.github/workflows/deploy.yml`**

Mirrors plcc-ng's docs deploy (fetch-depth 0, git identity for mike, shared concurrency group), simplified to this repo's model: every push to main redeploys `dev`.

```yaml
name: Deploy

on:
  push:
    branches: [main]

permissions:
  contents: write

concurrency:
  group: docs-deploy
  cancel-in-progress: false

jobs:
  deploy-dev:
    name: Deploy dev docs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - name: Configure git for mike
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
      - name: Deploy dev
        run: |
          mike deploy --push dev
          if ! mike list 2>/dev/null | grep -qw 'latest'; then
            mike set-default --push dev
          fi
```

- [ ] **Step 3: Write `.github/workflows/release.yml`**

```yaml
name: Release edition

on:
  workflow_dispatch:
    inputs:
      edition:
        description: "Edition name, e.g. 2026.09"
        required: true
        type: string

permissions:
  contents: write

concurrency:
  group: docs-deploy
  cancel-in-progress: false

jobs:
  release:
    name: Cut edition
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - name: Configure git for mike
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
      - name: Deploy edition
        run: |
          mike deploy --push --update-aliases "${{ inputs.edition }}" latest
          mike set-default --push latest
```

- [ ] **Step 4: Commit, PR, merge**

```bash
git add .github/workflows/deploy.yml .github/workflows/release.yml
git commit -m "ci: add mike deploy (dev) and edition release workflows"
git push -u origin deploy-pipeline
gh pr create --base main --title "ci: deploy pipeline (mike dev + editions)" \
  --body "Work item 4 of docs/superpowers/specs/2026-07-13-textbook-site-design.md. After merge: enable GitHub Pages on gh-pages."
```

Merge the PR. The merge itself triggers the first `Deploy` run, which creates `gh-pages`.

- [ ] **Step 5: Verify the deploy run and enable GitHub Pages**

```bash
gh run watch --repo ourPLCC/course-materials-ng $(gh run list --workflow Deploy --limit 1 --json databaseId -q '.[0].databaseId')
git fetch origin && git branch -r --list 'origin/gh-pages'
gh api -X POST repos/ourPLCC/course-materials-ng/pages \
  -f "source[branch]=gh-pages" -f "source[path]=/"
```

Expected: run succeeds; `origin/gh-pages` exists; Pages API returns 201. (Web-UI alternative: Settings → Pages → Deploy from branch → `gh-pages` / root.)

- [ ] **Step 6: Verify the live site**

```bash
sleep 90
curl -sSLo /dev/null -w '%{http_code}\n' https://ourplcc.github.io/course-materials-ng/
curl -sSL https://ourplcc.github.io/course-materials-ng/dev/ | grep -o '<title>[^<]*'
```

Expected: `200`; title contains the site name. Confirm the version selector shows `dev` in a browser. Do **not** run the release workflow yet — the first named edition is cut when the book is ready for readers.

---

### Task 5: README, CONTRIBUTING, licensing

Work item 5. Branch: `docs-and-licensing`. May start any time after Task 2, but its README links assume the live site, so merge it after Task 4 verifies.

**Files:**
- Rewrite: `README.md` (replace current course-notes description — its JNotes/slide-set content describes reference material now covered by directory names)
- Rewrite: `CONTRIBUTING.md` (currently a one-line pointer to the plcc wiki)
- Create: `REUSE.toml` (repo root)
- Create: `LICENSES/CC-BY-SA-4.0.txt`

**Interfaces:**
- Consumes: `make install/serve/build` (Task 2), release model (Task 4), `style-guide.md` at repo root (Task 2).

- [ ] **Step 1: Branch**

```bash
git checkout main && git pull && git checkout -b docs-and-licensing
```

- [ ] **Step 2: Rewrite `README.md`**

```markdown
# course-materials-ng

Course materials for an upper-level programming languages course using
[PLCC](https://github.com/ourPLCC/plcc). The centerpiece is a collaboratively
written textbook in `textbook/`; the other directories hold reference
materials the authors draw from.

- **Read the textbook:** <https://ourplcc.github.io/course-materials-ng/>
- **Contribute:** see [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

Textbook content (`textbook/`) is licensed under
[CC-BY-SA-4.0](LICENSES/CC-BY-SA-4.0.txt) (see `REUSE.toml`). Other
directories carry their own licenses: the repository's root
[LICENSE](LICENSE) (GPL-3.0) and per-directory annotations such as
`Jackson/REUSE.toml` remain in force for their content.
```

- [ ] **Step 3: Rewrite `CONTRIBUTING.md`**

```markdown
# Contributing

## Textbook

The textbook lives in `textbook/` and is published to
<https://ourplcc.github.io/course-materials-ng/>.

### Workflow

Use short-lived branches and pull requests against `main`. Fork only if you
don't have write access. CI runs a strict MkDocs build (required) and an
external link check (informational) on every PR. Merging to `main`
automatically publishes the `dev` version of the site.

### Development environment

You need Python 3 and GNU Make.

    make install   # create .venv and install pinned dependencies
    make serve     # live preview at http://localhost:8000
    make build     # strict build — the exact check CI runs

### Linking between pages

Link by anchor id, not by file path. Give headings explicit ids and reference
them with mkdocs-autorefs syntax:

    ## Environments {#environments}   <!-- in any chapter -->

    ... as described in [environments][] ...   <!-- from anywhere else -->

Id-based links survive file moves and renames; only renaming the id itself
requires a search-and-replace.

### Writing conventions

See [style-guide.md](style-guide.md).

### Releases

Every merge to `main` republishes the `dev` version. Named editions
(e.g. `2026.09`) are cut by a maintainer via the **Release edition** workflow
(Actions → Release edition → Run workflow); readers land on the newest
edition (`latest`) by default, and instructors can pin courses to a specific
edition via the site's version selector.

## Everything else

For the PLCC project itself, see
<https://github.com/ourPLCC/plcc/wiki/Contributing>.
```

- [ ] **Step 4: Add REUSE licensing for `textbook/`**

```bash
mkdir -p LICENSES
curl -fsSL -o LICENSES/CC-BY-SA-4.0.txt \
  https://raw.githubusercontent.com/spdx/license-list-data/main/text/CC-BY-SA-4.0.txt
head -1 LICENSES/CC-BY-SA-4.0.txt
```

Expected: first line names the Creative Commons Attribution-ShareAlike 4.0 license.

Write `REUSE.toml` (repo root; mirrors the convention in `Jackson/REUSE.toml` and plcc-ng):

```toml
version = 1
SPDX-PackageName = "course-materials-ng"
SPDX-PackageSupplier = "PLCC Community <https://discord.gg/EVtNSxS9E2>"
SPDX-PackageDownloadLocation = "https://github.com/ourPLCC/course-materials-ng"

[[annotations]]
path = "textbook/**"
precedence = "aggregate"
SPDX-FileCopyrightText = "PLCC Community <https://discord.gg/EVtNSxS9E2>"
SPDX-License-Identifier = "CC-BY-SA-4.0"
```

- [ ] **Step 5: Verify**

```bash
make build
pipx run reuse lint || true
```

Expected: strict build still passes (README/CONTRIBUTING are outside `docs_dir`, so this is a regression check). `reuse lint` is informational — this repo isn't fully REUSE-compliant (only `textbook/` and `Jackson/` are annotated); confirm it reports `textbook/**` as CC-BY-SA-4.0 licensed rather than missing.

- [ ] **Step 6: Commit and PR**

```bash
git add README.md CONTRIBUTING.md REUSE.toml LICENSES/CC-BY-SA-4.0.txt
git commit -m "docs: rebuild README/CONTRIBUTING; license textbook/ as CC-BY-SA-4.0"
git push -u origin docs-and-licensing
gh pr create --base main --title "docs: README, contributor guide, textbook licensing" \
  --body "Work item 5 of docs/superpowers/specs/2026-07-13-textbook-site-design.md."
```

Merge after review.
