# global-ai-skills

One combined repo of AI agent skills. Install any or all of them with a single `npx` command — each skill lives in its own folder under `skills/`.

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

## Available skills

| Flag | Installs | Source |
|------|----------|--------|
| `--mobile-app-setup` | `mobile-app-setup` | github.com/ejjat0909/mobile-app-setup |
| `--ui-ux-pro-max` | `ui-ux-pro-max` | github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| `--anti-slop` | `antislop`, `antislop-code`, `antislop-copywriting`, `antislop-human`, `antislop-layoutmobile`, `antislop-ui` | github.com/miqdadbadjuber/anti-slop |

`--anti-slop` is a group: it installs the core `antislop` skill plus its 5 companion skills.

## Options

| Option | Effect |
|--------|--------|
| `--all` | Install every skill (same as no flag) |
| `--project` | Install to `./.claude/skills` instead of `~/.claude/skills` |
| `--dir=<path>` | Install to a custom directory |
| `-h`, `--help` | Show help |

## Layout

```
skills/
  mobile-app-setup/       SKILL.md
  ui-ux-pro-max/          SKILL.md + references/ scripts/
  antislop/               SKILL.md   (anti-slop core)
  antislop-code/          SKILL.md
  antislop-copywriting/   SKILL.md
  antislop-human/         SKILL.md + contrast checker
  antislop-layoutmobile/  SKILL.md
  antislop-ui/            SKILL.md
bin/install.js            zero-dependency installer
```

## Adding a new skill

1. Drop a folder with a `SKILL.md` under `skills/`.
2. If it's a multi-folder bundle, add it to `GROUPS` in `bin/install.js`.

That's it — the folder name becomes its `--flag` automatically.
