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
