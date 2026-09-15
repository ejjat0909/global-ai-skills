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

`--anti-slop` and `--ecc` are groups: one flag installs all the folders in that
bundle. Group membership is defined in `groups.json`.

## Options

| Option | Effect |
|--------|--------|
| `--all` | Install every skill (same as passing no skill flag) |
| `--update`, `-u` | Refresh already-installed skills to the latest version |
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

## Adding a new skill

1. Drop a folder with a `SKILL.md` under `skills/`.
2. If it's a multi-folder bundle, add it to `GROUPS` in `bin/install.js`.

That's it — the folder name becomes its `--flag`, and `--all` / `--update` pick
it up automatically.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add a skill, test it, and open a PR.

