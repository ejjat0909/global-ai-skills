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

`--anti-slop` is a group: it installs the core `antislop` skill plus its 5 companion skills.

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
- Multi-folder bundles (like anti-slop) are declared in the `GROUPS` map in
  `bin/install.js`, so one flag installs several folders.
- Install/update copies whole skill folders into the target `.claude/skills`
  directory. Update deletes each target folder first, then copies fresh, so
  removed or renamed files don't linger.

## Adding a new skill

1. Drop a folder with a `SKILL.md` under `skills/`.
2. If it's a multi-folder bundle, add it to `GROUPS` in `bin/install.js`.

That's it — the folder name becomes its `--flag`, and `--all` / `--update` pick
it up automatically.

## Contributing

Contributions that add a new skill or fix an existing one are welcome.

### Add a skill

1. **Fork and clone** this repo.
2. **Create the skill folder** under `skills/`. The folder name is the skill's
   install flag, so use a clear, lowercase, hyphenated name (e.g.
   `skills/my-skill/`). It must contain a `SKILL.md`. Supporting files
   (`references/`, `scripts/`, `data/`, etc.) can sit alongside it and are
   copied as-is.
3. **Bundle of several folders?** (like anti-slop's 6 skills) — add an entry to
   the `GROUPS` map at the top of `bin/install.js` so one flag installs them all:

   ```js
   const GROUPS = {
     'my-bundle': ['my-skill-core', 'my-skill-ui', 'my-skill-code'],
   };
   ```

   Skills not listed in `GROUPS` are standalone and get a `--<folder-name>` flag
   automatically — no code change needed.
4. **Test locally** before opening a PR:

   ```bash
   node bin/install.js --my-skill --dir=/tmp/test   # install just yours
   node bin/install.js --dir=/tmp/test-all          # install everything
   node bin/install.js --update --dir=/tmp/test     # update path
   node bin/install.js --help                        # your flag should appear
   ```

   Confirm the folder lands under the target dir with its `SKILL.md` intact.
5. **Update the README** — add your skill to the *Available skills* table with
   its flag and upstream source.
6. **Open a PR** describing the skill and where it came from. Keep unrelated
   changes out of the diff.

### Guidelines

- **One skill = one folder** with a `SKILL.md`. Don't nest skills.
- **Keep the installer zero-dependency** — `bin/install.js` uses only Node
  built-ins (`fs`, `path`, `os`). Don't add npm dependencies.
- **Don't commit a nested `.git`** — copy skill *contents*, not the source
  repo's `.git` directory.
- **Credit the source** — if a skill comes from another repo, cite it in the
  README table and keep its `LICENSE` if required.
- **Match existing style** — small, focused commits; no unrelated reformatting.

### Report an issue

Open a GitHub issue with the command you ran, what you expected, and what
happened (include your OS and Node version).

