# Contributing

Contributions that add a new skill or fix an existing one are welcome.

> **Full A–Z guide with mandatory testing steps:**
> [docs/ADDING-SKILLS-AND-PLUGINS.md](docs/ADDING-SKILLS-AND-PLUGINS.md).
> The quick version is below; the guide has every command and every test.

## Add a skill

1. **Fork and clone** this repo.
2. **Create the skill folder** under `skills/`. The folder name is the skill's
   install flag, so use a clear, lowercase, hyphenated name (e.g.
   `skills/my-skill/`). It must contain a `SKILL.md`. Supporting files
   (`references/`, `scripts/`, `data/`, etc.) can sit alongside it and are
   copied as-is.
3. **Bundle of several folders?** (like anti-slop's 6 skills or ecc's 292) — add
   an entry to `groups.json` so one flag installs them all:

   ```json
   {
     "my-bundle": ["my-skill-core", "my-skill-ui", "my-skill-code"]
   }
   ```

   Skills not listed in `groups.json` are standalone and get a `--<folder-name>`
   flag automatically — no code change needed.
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

## Add a custom skill (one you authored yourself)

Not vendoring an existing skill from elsewhere — writing a brand-new one from
scratch. Same steps as "Add a skill" above (folder, `groups.json` if it's a
bundle, test, README), plus your `SKILL.md` frontmatter **must** have `name:`
and `description:` (CI checks this). Full guide with frontmatter template:
[docs/ADDING-CUSTOM-SKILLS.md](docs/ADDING-CUSTOM-SKILLS.md).

## Add a plugin

Plugins are either a published npm package (agent tooling — browsers, MCP
servers, etc.), installed globally, or a local setup script (machine config —
symlinks, scaffolding). Never vendored into `skills/`.

### npm plugin

1. Add an entry to `plugins.json`:

   ```json
   {
     "my-plugin": {
       "package": "@scope/my-plugin",
       "bin": ["my-plugin"],
       "description": "What it does",
       "source": "https://github.com/owner/repo"
     }
   }
   ```

2. It must be published to npm (the installer runs `npm install -g <package>`).
3. Test: `node bin/install.js --plugins-only` — the package should install and
   its `bin` land on your PATH.
4. Add it to the *Plugins* table in the README.

### Custom (script) plugin — one you wrote yourself

Full guide: [docs/ADDING-CUSTOM-PLUGINS.md](docs/ADDING-CUSTOM-PLUGINS.md).
Put your script under `plugins/<name>/`, reference it in `plugins.json` with
`"type": "script"`, make it idempotent, test with `--plugins-only` twice.

## Guidelines

- **One skill = one folder** with a `SKILL.md`. Don't nest skills.
- **Keep the installer zero-dependency** — `bin/install.js` uses only Node
  built-ins (`fs`, `path`, `os`). Don't add npm dependencies.
- **Don't commit a nested `.git`** — copy skill *contents*, not the source
  repo's `.git` directory.
- **Credit the source** — if a skill comes from another repo, cite it in the
  README table and keep its `LICENSE` if required.
- **Match existing style** — small, focused commits; no unrelated reformatting.

## Report an issue

Open a GitHub issue with the command you ran, what you expected, and what
happened (include your OS and Node version).
