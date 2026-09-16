# global-ai-skills

One combined repo of AI agent skills. Install any or all of them with a single `npx` command — each skill lives in its own folder under `skills/`. Update them the same way.

## Install

All skills (default):

```bash
npx github:ejjat0909/global-ai-skills
```

Only specific skills — add a flag per skill/group:

```bash
npx github:ejjat0909/global-ai-skills --anti-slop
npx github:ejjat0909/global-ai-skills --anti-slop --ui-ux-pro-max
npx github:ejjat0909/global-ai-skills --mobile-app-setup
```

By default skills install to `~/.claude/skills`. Use `--project` for the current
project (`./.claude/skills`) or `--dir=<path>` for anywhere else.

## Update

`npx` always fetches the latest repo, so updating just re-copies the newest
version over what you already have. `--update` refreshes **only the skills that
are already installed** in the target directory (it never installs new ones),
and it removes stale files so each skill folder is a clean copy of the latest.

Update every installed skill:

```bash
npx github:ejjat0909/global-ai-skills --update
```

Update only specific installed skills:

```bash
npx github:ejjat0909/global-ai-skills --update --anti-slop
```

Update skills installed in a project / custom dir — point `--update` at the same
location you installed to:

```bash
npx github:ejjat0909/global-ai-skills --update --project
npx github:ejjat0909/global-ai-skills --update --dir=/path/to/skills
```

If nothing matching is installed there, it says so and does nothing.

## Available skills

| Flag | Installs | Source |
|------|----------|--------|
| `--mobile-app-setup` | `mobile-app-setup` | github.com/ejjat0909/mobile-app-setup |
| `--ui-ux-pro-max` | `ui-ux-pro-max` | github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| `--anti-slop` | `antislop`, `antislop-code`, `antislop-copywriting`, `antislop-human`, `antislop-layoutmobile`, `antislop-ui` | github.com/miqdadbadjuber/anti-slop |
| `--ecc` | 292 ECC skills (accessibility, api-design, agent-*, benchmark, brand-voice, security-review, tdd-workflow, …) | github.com/affaan-m/ecc |
| `--pwa-page-redesign` | `pwa-page-redesign` | authored in this repo |
| `--ponytail` | `ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`, `ponytail-review` | github.com/dietrichgebert/ponytail |
| `--daisyui` | `daisyui` | github.com/saadeghi/daisyui |
| `--watermelon-ui` | `watermelon-ui` | github.com/WatermelonCorp/watermelon-platform |
| `--make-interfaces-feel-better-watermelon` | `make-interfaces-feel-better-watermelon` | github.com/WatermelonCorp/watermelon-platform |

`--anti-slop` and `--ecc` are groups: one flag installs all the folders in that
bundle. Group membership is defined in `groups.json`.

## Plugins

Plugins install **by default** alongside skills (unless `--no-plugins`). Two
kinds:
- **npm**: a published package, installed globally so its CLI/MCP binaries are
  on PATH.
- **script**: a bundled local setup script for machine config (symlinks,
  scaffolding) — runs via `bash`, no npm involved.

| Plugin | Type | What it does | Source |
|--------|------|---------------|--------|
| `camofox-browser` | npm | Installs `@askjo/camofox-browser` globally | github.com/jo-inc/camofox-browser |
| `shared-ai-memory` | script | Extracts existing per-agent memory into `~/.shared-ai-memory`, symlinks every agent's memory/skills dir to it, seeds `PERSONALITY.md`, and appends a read/update-shared-memory instruction to each agent's global instructions file | authored in this repo |

```bash
npx github:ejjat0909/global-ai-skills                 # skills + plugins (default)
npx github:ejjat0909/global-ai-skills --no-plugins    # skills only
npx github:ejjat0909/global-ai-skills --plugins-only  # plugins only, no skills
npx github:ejjat0909/global-ai-skills --update        # updates installed skills + plugins
```

npm plugins need Node/npm on PATH (npx already implies that); `npm install -g`
both installs and upgrades, so `--update` refreshes them. Script plugins are
written to be idempotent — safe to re-run on every install/update. If a plugin
fails, the command keeps going and prints how to run it manually.

## Options

| Option | Effect |
|--------|--------|
| `--all` | Install every skill (same as passing no skill flag) |
| `--update`, `-u` | Refresh already-installed skills **and** plugins to the latest version |
| `--no-plugins` | Skip plugin installation (skills only) |
| `--plugins-only` | Install/update only the plugins, no skills |
| `--project` | Install/update in `./.claude/skills` instead of `~/.claude/skills` |
| `--dir=<path>` | Install/update in a custom directory |
| `-h`, `--help` | Show help |

Flags combine: e.g. `--update --anti-slop --project`.

## Layout

```
skills/
  mobile-app-setup/       SKILL.md
  ui-ux-pro-max/          SKILL.md + references/ scripts/ data/
  antislop/               SKILL.md   (anti-slop core)
  antislop-code/          SKILL.md
  antislop-copywriting/   SKILL.md
  antislop-human/         SKILL.md + contrast checker
  antislop-layoutmobile/  SKILL.md
  antislop-ui/            SKILL.md
  ...                     292 more from the ecc bundle
groups.json               skill bundle definitions (--anti-slop, --ecc)
plugins.json              plugin definitions (npm packages + local scripts)
plugins/                  local script plugins (e.g. shared-ai-memory/setup.sh)
bin/install.js            zero-dependency installer
```

## How it works

- The installer is a single zero-dependency Node script (`bin/install.js`).
- Each folder under `skills/` containing a `SKILL.md` is an installable skill;
  its folder name becomes its `--flag` automatically.
- Multi-folder bundles (like anti-slop and ecc) are declared in `groups.json`,
  so one flag installs several folders.
- Install/update copies whole skill folders into the target `.claude/skills`
  directory. Update deletes each target folder first, then copies fresh, so
  removed or renamed files don't linger.
- Plugins listed in `plugins.json` install after skills (unless `--no-plugins`):
  `type: "npm"` (default) runs `npm install -g <package>`; `type: "script"` runs
  a bundled script under `plugins/<name>/` for local machine setup.

## Adding a new skill

1. Drop a folder with a `SKILL.md` under `skills/`.
2. If it's a multi-folder bundle, add it to `groups.json`.

To add a **plugin**: an npm package needs only an entry in `plugins.json` with
its published package name; a custom local-setup plugin needs a script under
`plugins/<name>/` plus a `plugins.json` entry with `"type": "script"` — see
[docs/ADDING-CUSTOM-PLUGINS.md](docs/ADDING-CUSTOM-PLUGINS.md).

That's it — the folder name becomes its `--flag`, and `--all` / `--update` pick
it up automatically.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for a quick start, and
**[docs/ADDING-SKILLS-AND-PLUGINS.md](docs/ADDING-SKILLS-AND-PLUGINS.md)** for the
full A–Z guide (with required testing steps) on adding a skill or plugin. AI
agents: an `AGENTS.md` / `CLAUDE.md` at the repo root points you to that guide
automatically.

