# Bashmatic® — Project Guide for Claude

> A BASH framework of ~900 helper functions (“a BASH DSL for humans”), focused on
> beautiful terminal output, consistent command execution, and self-documenting
> scripts. Loads in under 200ms. MIT licensed.

- Current version: see `.version` (authoritative; README is regenerated from it).
- Primary README: `README.adoc` (generated PDF: `README.pdf`).
- Auto-generated docs: `doc/FUNCTIONS.adoc`, `doc/USAGE.md` (+ PDFs), `doc/CHANGELOG.md`.
- Install target on user machines: `~/.bashmatic` (this repo is checked out there).

## Quick Orientation

| You want to… | Look at |
| --- | --- |
| Add a new helper function | `lib/<module>.sh` (new file or existing module) |
| Add a new user-facing executable | `bin/<name>` (chmod +x, no `.sh` suffix) |
| Write or run tests | `test/*_test.bats` + `bin/specs` |
| Understand loading / bootstrap | `init.sh`, `init-helpers.sh`, `.init.sh` |
| Install flow | `bin/bashmatic-install` |
| PostgreSQL helpers | `lib/db.sh`, `lib/db_cli.sh`, `lib/db_top.sh`, `bin/db`, `bin/dbtop` |
| Output / UI primitives | `lib/output*.sh`, `lib/color.sh`, `lib/progress-bar.sh` |
| Runtime execution framework | `lib/run.sh`, `lib/runtime.sh`, `lib/runtime-config.sh` |
| DSL predicates | `lib/is.sh` |

`lib/` contains ~75 modules, one per concern. `bin/` contains end-user
executables (`specs`, `dev-setup`, `db`, `tablet`, `adoc2pdf`, `ruby-install`,
`bashmatic-install`, …).

## Programming Style

Bashmatic is heavy on Ruby-flavored DSL idioms. Conventions enforced throughout:

- **Namespaces use `.`, not `::` or `_`.** Good: `git.sync`, `array.join`,
  `run.set-next`. Avoid `git_sync` for public APIs (underscores appear inside
  modules but the public surface uses dots).
- **Leading dot = private.** `.run.env`, `.output.set-indent` are internal.
- **No abbreviations.** `file.last-modified-year`, not `flmy`.
- **Defensive on empty args.** Public functions that require arguments must
  print usage via `usage-box` / `usage` helpers when called bare, not silently
  fail.
- **Chain with `&&` / `||`.** Functions return exit status; that’s the DSL glue
  (`is.a-directory "$d" && { … }`).
- **Module file = prefix.** Functions in `lib/array.sh` generally start with
  `array.`, functions in `lib/git.sh` with `git.`, etc.
- **Use Google’s Bash Style Guide** (https://google.github.io/styleguide/shell.xml)
  as the baseline.
- Rely on `run "<command>"` (from `lib/run.sh`) to get the pretty status/duration
  output rather than executing commands bare. `run.set-next` / `run.set-all`
  configure behavior (`abort-on-error`, `show-output-on/off`, `dry-run-on/off`,
  etc.).

### Shell tooling the code assumes

Bashmatic depends on GNU utilities and will attempt to install/upgrade them:

- `gsed` (GNU sed) and `gawk` — install via `brew install gnu-sed gawk` on macOS.
- `coreutils` on macOS.
- `grep -E` via `${GrepCommand}`; ripgrep is not assumed.
- BASH 4+ for the full feature set. BASH 3 (the macOS default) has partial
  compatibility — `bashmatic-install` upgrades it when needed.
- ZSH is ~90% compatible but not the primary target.

Where a tool name differs (`sed` vs `gsed`, `awk` vs `gawk`, `grep` vs `ggrep`),
prefer the GNU variant in new code. `lib/sedx.sh` wraps this.

## Testing

We use **Bats** (`bats-core` + `bats-support`, `bats-assert`, `bats-file`) via
`bin/specs`, which bootstraps Bats from sources into `.bats-prefix/`.

```bash
bin/specs                      # run the whole suite
bin/specs is                   # shortcut → test/is_test.bats
bin/specs test/array_test.bats # full path also works
bin/specs -p                   # parallel (requires GNU parallel)
bin/specs -t                   # TAP output
bin/specs -r                   # reinstall Bats first
bin/specs -c                   # keep going on failures
```

Test layout:

- `test/*_test.bats` — the tests themselves, one file per module.
- `test/darwin/*.bats`, `test/linux/*.bats` — OS-specific tests, picked up by
  matching `${BASHMATIC_OS}`.
- `test/helpers/test-lib.sh` — the runner implementation sourced by `bin/specs`
  (find project root, install Bats, parse flags, dispatch).
- `test/test_helper.bash`, `test/load.bash`, `test/test_helper/` — Bats helper
  libraries auto-installed on first run.
- `test/fixtures/`, `test/libs/` — supporting data.

### Short-name resolution (`bin/specs is`)

Names are resolved by `specs.utils.get-filename` in the order:
`test/<name>` → `test/<name>.bats` → `test/<name>_test.bats`.

### Linux-vs-macOS regressions

Some failures are macOS-only because of BSD-tool differences (`sed`, `date`,
`stat`, `readlink`, `grep`) or because GNU `coreutils` / `gnu-sed` isn’t on
PATH. When a test runs on Linux CI but not locally on macOS, inspect:

- Whether the module reaches for `sed` vs `gsed` / `awk` vs `gawk`.
- Printf format strings that are empty (`printf ""`) — BSD bash can emit
  “invalid number” warnings that GNU tolerates.
- `find` flag ordering (`-maxdepth` must precede expressions).

## Documentation Pipeline

Docs are auto-generated; don’t hand-edit the generated files:

| Artifact | Regenerated by |
| --- | --- |
| `doc/FUNCTIONS.adoc` + PDF | `make update-functions` |
| `doc/USAGE.md` + PDF | `make update-usage` |
| `doc/CHANGELOG.md` | `make update-changelog` (needs `GITHUB_TOKEN`) |
| `README.pdf` | `make update-readme` (uses `bin/adoc2pdf`) |

`make update` runs all of them plus `update-copyright` and `git add .`. Ruby
(version pinned in `.ruby-version`) + the Gemfile are used for the
`asciidoctor-pdf` toolchain only — Bashmatic itself has no Ruby runtime
dependency.

The function-documentation format is an `shdoc` fork (see `doc/SHDOC.md` and
`bin/shdoc`). Headers look like:

```bash
# @description Short sentence.
# @example
#   foo bar
# @arg $1 string What it is
# @exitcode 0 Success
```

## Key Subsystems

- **Runtime framework** (`lib/run*.sh`) — `run`, `run.set-next`, `run.set-all`,
  `run.ui.ask`, `run.inspect-*`. Every significant command in a Bashmatic-based
  script should go through `run` so the user sees it + its timing + its exit
  code.
- **Output** (`lib/output*.sh`, `lib/color.sh`) — `h1`/`h2`/`h3`, `hr`, `box.*`,
  `hl.*`, `inf` + `ok:` / `not-ok:` closers, `success`, `warning`, `error`,
  `info`, `dbg`. Many names mirror HTML elements intentionally.
- **DSL predicates** (`lib/is.sh`) — `is.a-function`, `is.a-directory`,
  `is.not-blank`, `is.sourced-in`, etc. Designed to chain with `&&` / `||`.
- **Arrays / util** (`lib/array.sh`, `lib/util.sh`) — `array.join`,
  `array.includes`, `array.to.csv`, `util.ver-to-i`, `util.shell-init-files`.
- **Package / platform** (`lib/brew.sh`, `lib/package.sh`, `lib/osx.sh`) —
  `brew.install.package`, `package.install`, OS detection via
  `${BASHMATIC_OS}`.
- **DB tooling** (`lib/db*.sh`, `bin/db`, `bin/dbtop`, `bin/tablet`) — driven by
  `~/.db/database.yml` (Rails-compatible format). See README §Example V.
- **Runtime config** (`lib/runtime-config.sh`) — persists per-user flags and
  behavioral settings.

## Conventions for Commits & Releases

- Branches: feature branches off `main`; the current working branch is visible
  via `git status`.
- Tags: `v<major>.<minor>.<patch>` matching `.version`. `make tag` creates the
  tag and force-pushes; `make release` creates a GitHub release via `gh`.
- Release includes regenerating all docs (`make update`) so the PDFs in the
  repo stay current.
- Commit messages: imperative mood, one logical change per commit. The README
  PDF is large — only regenerate/commit it when README content changed.

## Installing The Framework

Typically done via curl:

```bash
bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install -q"
```

This URL redirects to the script ./bin/bashmatic-install on the main branch, and runs it
with the -q flag to suppress extra output. Note that this also means that the
bashmatic.re1.re domain must be maintained with the fresh SSL certificate.

## Public Site

There is a public marketing site https://bashmatic.dev

The repo for the site is https://github.com/kigster/bashmatic.dev

The repo for Bashmatic is https://github.com/kigster/bashmatic

## Loading Bashmatic From a Shell Script

Two common patterns:

```bash
# 1) Full library (800+ functions), fastest path — check if ~/.bashmatic exists,
#    and if not install it via CURL. Then load it.
[[ -d ~/.bashmatic ]] || bash -c "$(curl -fsSL https://bashmatic.re1.re); bashmatic-install -q"
source "${BASHMATIC_HOME:-$HOME/.bashmatic}/init"

# 2) Inside a test (Bats): test/test_helper.bash already sources init.sh.
```

Scripts that should work both sourced and executed use
`bashmatic.validate-subshell` or `bashmatic.validate-sourced-in` (see README
FAQ).

## Things to Avoid

- Don’t add helpers that duplicate existing namespaces. Grep `lib/` or run
  `bashmatic.functions-from <prefix>` first.
- Don’t add `.sh` extensions to files in `bin/` — they’re user-facing commands.
- Don’t commit regenerated PDFs unless the source `.adoc`/`.md` actually changed.
- Don’t use abbreviations in new public function names.
- Don’t regress BASH 3 compatibility in modules that are sourced during
  `bashmatic-install` bootstrap (that script may run before BASH 5 is
  installed). The rest of the library can assume BASH 4+.
- Don’t rely on `readlink -f` (GNU-only); use `realpath_portable` defined in
  `init.sh`.

