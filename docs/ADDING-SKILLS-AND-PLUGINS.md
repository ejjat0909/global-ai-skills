# Contributor Guide: Adding a Skill or Plugin (A–Z)

This is the complete, step-by-step reference for adding a **skill** or a
**plugin** to `global-ai-skills`. It is written to be followed literally — by a
human or by an AI agent — with no prior knowledge of the repo. Every command
here is real and runnable. Do not skip the testing sections; a contribution is
not done until the tests in this document pass.

If anything in this guide is wrong or out of date, fix it in the same PR.

---

## 0. Mental model — how this repo works

There are exactly two kinds of things you can contribute:

| Kind | What it is | Where it lives | How it installs |
|------|-----------|----------------|-----------------|
| **Skill** | A folder containing a `SKILL.md` (plus optional `references/`, `scripts/`, `data/`). Pure files. | `skills/<name>/` in this repo (vendored) | Copied into the user's `.claude/skills` directory |
| **Plugin** | A **published npm package** — agent tooling like a browser, an MCP server, a CLI. Has its own dependencies / binaries. | `plugins.json` (a reference only — the code is NOT vendored) | `npm install -g <package>` |

**Decision rule — skill or plugin?**

- Is it just Markdown + a few helper files, self-contained, no build step, no
  dependencies to install? → **Skill.** Vendor the folder.
- Is it a program with dependencies, a server, a native binary, or its own npm
  `package.json` with a `bin`? → **Plugin.** Reference it in `plugins.json`;
  do **not** copy its source into `skills/`.

> Why not vendor plugins? They carry `node_modules`, native binaries, and build
> steps. Copying them bloats the repo and breaks on install. `npm install -g`
> is the correct, supported path.

The single installer is `bin/install.js` — a **zero-dependency Node script**
(only Node built-ins: `fs`, `path`, `os`, `child_process`). It reads three data
files:

- `skills/` — every subfolder with a `SKILL.md` is an installable skill.
  The folder name automatically becomes its `--<folder-name>` flag.
- `groups.json` — maps one flag to many skill folders (bundles like
  `--anti-slop`, `--ecc`).
- `plugins.json` — maps a plugin name to its npm package.

You will almost never edit `bin/install.js` itself. Adding skills and plugins is
done by adding **files and data**, not code.

---

## 1. One-time setup

```bash
# 1. Fork the repo on GitHub, then clone YOUR fork:
git clone https://github.com/<your-username>/global-ai-skills.git
cd global-ai-skills

# 2. Confirm Node is available (needed to run and test the installer):
node --version    # any Node 14+ is fine
npm --version

# 3. Confirm the installer runs at all:
node bin/install.js --help
```

If `--help` prints usage with a list of skill flags and a Plugins section,
you're ready.

Create a branch for your change:

```bash
git checkout -b add-<your-skill-or-plugin-name>
```

---

## 2. Adding a SKILL

### 2.1 Get the skill content

A skill is a folder that contains a `SKILL.md` file. It may come from:

- Another GitHub repo (most common), or
- Something you wrote yourself.

If it comes from another repo, clone it to a temp location and find the
`SKILL.md`:

```bash
git clone --depth 1 https://github.com/<owner>/<repo>.git /tmp/src
find /tmp/src -name SKILL.md -not -path '*/.git/*'
```

Note **where** the `SKILL.md` sits — repos vary. Common shapes:

- `repo/SKILL.md` — the whole repo is one skill.
- `repo/<framework>/SKILL.md` — the skill is in a subfolder.
- `repo/.claude/skills/<name>/SKILL.md` — nested under a `.claude` dir.
- `repo/skills/<name>/SKILL.md` — a collection of many skills.

### 2.2 Choose the folder name (this is the install flag)

The folder name under `skills/` becomes the user's `--flag`, so pick a clear,
lowercase, hyphenated name:

- Good: `mobile-app-setup`, `ui-ux-pro-max`, `security-review`
- Bad: `MySkill`, `skill_1`, `stuff`

It must be **unique** — check for collisions first:

```bash
ls skills/ | grep -i <proposed-name>
```

If that prints an existing folder, pick a different name.

### 2.3 Copy the skill into `skills/`

**One skill = one folder with a `SKILL.md` at its top level.** Copy the skill's
*contents*, never a nested `.git` directory.

Single-folder skill:

```bash
mkdir -p skills/<your-skill-name>
cp /tmp/src/path/to/SKILL.md skills/<your-skill-name>/SKILL.md
# include supporting files if the skill has them:
cp -R /tmp/src/path/to/references skills/<your-skill-name>/   # if present
cp -R /tmp/src/path/to/scripts    skills/<your-skill-name>/   # if present
```

If the source folder already has the right shape (a folder containing
`SKILL.md` and its assets), copy the whole folder in one shot:

```bash
cp -R /tmp/src/path/to/<skill-folder> skills/<your-skill-name>
```

### 2.4 CRITICAL: strip any nested `.git`

A nested `.git` will corrupt the repo. Always check and remove:

```bash
find skills/<your-skill-name> -name .git -maxdepth 3
# if anything prints, delete it:
find skills/<your-skill-name> -name .git -maxdepth 3 -exec rm -rf {} +
```

### 2.5 Verify the folder shape

```bash
# Must print a SKILL.md at the folder's top level:
ls skills/<your-skill-name>/SKILL.md

# The SKILL.md must start with YAML frontmatter (--- ... ---) and a name:
head -6 skills/<your-skill-name>/SKILL.md
```

If there's no `SKILL.md` directly inside the folder, the installer will not see
it as a skill. Fix the folder layout.

### 2.6 If it's a BUNDLE (many folders under one flag)

Some sources ship many skills at once (e.g. anti-slop = 6 skills, ecc = 292).
Give them **one folder each** under `skills/`, then add **one group flag** in
`groups.json` so a single `--flag` installs them all.

Copy each sub-skill folder in:

```bash
cp -R /tmp/src/skills/* skills/       # each subfolder must have its own SKILL.md
```

Then edit `groups.json` — add a key (the flag name) mapped to the list of folder
names:

```json
{
  "anti-slop": ["antislop", "antislop-code", "antislop-ui"],
  "ecc": ["accessibility", "api-design", "..."],
  "my-bundle": ["my-skill-core", "my-skill-ui", "my-skill-code"]
}
```

For a large bundle, generate the list programmatically instead of typing it:

```bash
node -e "const fs=require('fs');const d='/tmp/src/skills';const list=fs.readdirSync(d).filter(f=>fs.existsSync(d+'/'+f+'/SKILL.md')).sort();const g=JSON.parse(fs.readFileSync('groups.json'));g['my-bundle']=list;fs.writeFileSync('groups.json',JSON.stringify(g,null,2)+'\n');console.log('added',list.length,'folders')"
```

Validate the JSON after editing:

```bash
node -e "JSON.parse(require('fs').readFileSync('groups.json','utf8'));console.log('groups.json OK')"
```

> Folders **not** listed in any group are standalone and get a
> `--<folder-name>` flag automatically. Only put a skill in `groups.json` when
> several folders should install together under one flag.

### 2.7 TEST the skill install (required)

Run every check below. All must pass.

```bash
# a) Syntax of the installer is intact (you shouldn't have touched it, but verify):
node -c bin/install.js && echo "installer syntax OK"

# b) Your flag appears in help:
node bin/install.js --help | grep -- "--<your-skill-name>"

# c) Install ONLY your skill into a throwaway dir, skip plugins for speed:
rm -rf /tmp/test-skill
node bin/install.js --<your-skill-name> --no-plugins --dir=/tmp/test-skill

# d) The folder landed with its SKILL.md intact:
ls /tmp/test-skill/<your-skill-name>/SKILL.md
head -3 /tmp/test-skill/<your-skill-name>/SKILL.md

# e) Install-all still works and includes your skill:
rm -rf /tmp/test-all
node bin/install.js --no-plugins --dir=/tmp/test-all
ls /tmp/test-all/<your-skill-name>

# f) Update path works (drops stale files, restores fresh copy):
echo "STALE" > /tmp/test-skill/<your-skill-name>/JUNK.md
node bin/install.js --update --<your-skill-name> --no-plugins --dir=/tmp/test-skill
ls /tmp/test-skill/<your-skill-name>/JUNK.md 2>&1   # must say "No such file"
```

For a **bundle**, also verify the count:

```bash
rm -rf /tmp/test-bundle
node bin/install.js --my-bundle --no-plugins --dir=/tmp/test-bundle
ls /tmp/test-bundle | wc -l    # should equal the number of folders in your group
```

If any check fails, fix it before continuing. Common failures:

| Symptom | Cause | Fix |
|---------|-------|-----|
| Flag missing from `--help` | No `SKILL.md` directly in the folder | Move `SKILL.md` to the folder's top level |
| `Unknown skill or group` | Typo in flag / not copied | Check `ls skills/<name>` |
| Whole repo committed weirdly | Nested `.git` copied | Remove it (§2.4) |
| `Failed to parse groups.json` | Broken JSON | Re-validate (§2.6) |

### 2.8 Update the README table

Add a row to the **Available skills** table in `README.md`:

```markdown
| `--<your-skill-name>` | `<folder(s) installed>` | github.com/<owner>/<repo> |
```

---

## 3. Adding a PLUGIN

A plugin is a **published npm package**. You do not copy its code. You add a
reference in `plugins.json`, and the installer runs `npm install -g <package>`.

### 3.1 Confirm it's published to npm

```bash
npm view <package-name> version
```

If this errors with 404, the package is not on npm and **cannot** be added as a
plugin here. (Options: ask the author to publish it, or install from GitHub is
out of scope for this repo.)

Find the package name and its `bin` entries from the source repo:

```bash
git clone --depth 1 https://github.com/<owner>/<repo>.git /tmp/plug
node -e "const p=require('/tmp/plug/package.json');console.log('name:',p.name);console.log('bin:',JSON.stringify(p.bin))"
```

### 3.2 Add it to `plugins.json`

```json
{
  "camofox-browser": {
    "package": "@askjo/camofox-browser",
    "bin": ["camofox-browser", "camofox-browser-mcp"],
    "description": "Anti-detection Camoufox browser + MCP server for AI agents",
    "source": "https://github.com/jo-inc/camofox-browser"
  },
  "my-plugin": {
    "package": "@scope/my-plugin",
    "bin": ["my-plugin"],
    "description": "One-line description of what it does",
    "source": "https://github.com/owner/repo"
  }
}
```

Field meanings:

- `package` — exact npm package name (what `npm install -g` receives). **Required.**
- `bin` — the command name(s) the package exposes on PATH. Used for docs and
  your own verification. Read them from the package's `package.json` `bin`.
- `description` — one line, shown in `--help`.
- `source` — the upstream repo URL (credit + reference).

Validate the JSON:

```bash
node -e "JSON.parse(require('fs').readFileSync('plugins.json','utf8'));console.log('plugins.json OK')"
```

### 3.3 TEST the plugin install (required)

> This actually installs the package globally on your machine. That's expected —
> it's the only way to prove it works.

```bash
# a) Installer syntax intact:
node -c bin/install.js && echo "OK"

# b) Your plugin shows in help under "Plugins":
node bin/install.js --help | grep -A20 "Plugins"

# c) Install ONLY plugins (no skills):
node bin/install.js --plugins-only

# d) The package is installed globally and its bin is on PATH:
npm ls -g <package-name>
which <each-bin-name-from-your-bin-array>

# e) The default flow installs the plugin alongside skills:
rm -rf /tmp/test-combo
node bin/install.js --<some-skill> --dir=/tmp/test-combo
#   -> should install the skill AND print "✓ <plugin> installed"

# f) --no-plugins skips it:
rm -rf /tmp/test-np
node bin/install.js --<some-skill> --no-plugins --dir=/tmp/test-np
#   -> should install the skill and NOT touch npm
```

All of a–f must pass. If the plugin's `npm install -g` fails, the installer keeps
going and prints a manual command — but for a contribution, the install must
actually succeed on a normal machine.

### 3.4 Update the README table

Add a row to the **Plugins** table in `README.md`:

```markdown
| `<plugin-name>` | `<npm-package>` | github.com/<owner>/<repo> |
```

---

## 4. Final checklist before opening a PR

Run this whole block. Everything must pass.

```bash
# JSON files valid
node -e "JSON.parse(require('fs').readFileSync('groups.json','utf8'));JSON.parse(require('fs').readFileSync('plugins.json','utf8'));console.log('json OK')"

# Installer runs
node -c bin/install.js && node bin/install.js --help >/dev/null && echo "installer OK"

# No nested .git anywhere under skills/
test -z "$(find skills -name .git 2>/dev/null)" && echo "no nested .git OK"

# Full install to a temp dir works end to end
rm -rf /tmp/final && node bin/install.js --no-plugins --dir=/tmp/final >/dev/null && echo "install-all OK ($(ls /tmp/final | wc -l | tr -d ' ') skills)"
```

Then:

- [ ] README table updated (skills or plugins).
- [ ] Only your change is in the diff — no unrelated reformatting, no stray files.
- [ ] Source credited (repo URL in the README row; keep upstream `LICENSE` if required).
- [ ] Commit message describes what you added and where it came from.

Commit and push:

```bash
git add -A
git status          # review — should be ONLY your intended files
git commit -m "Add <skill|plugin> <name> from <source>"
git push -u origin add-<your-skill-or-plugin-name>
```

Open a PR on GitHub describing the skill/plugin and its source.

---

## 5. Rules (do not violate)

- **One skill = one folder** with a `SKILL.md` at its top level. Never nest skills.
- **Keep `bin/install.js` zero-dependency.** It uses only Node built-ins. Do not
  add npm dependencies to the installer.
- **Never commit a nested `.git`.** Copy skill *contents*, not the source repo.
- **Plugins are referenced, never vendored.** They go in `plugins.json` only.
- **Credit the source** in the README and keep upstream licenses where required.
- **Small, focused commits.** No unrelated reformatting or reindentation.
- **Test before PR.** The testing sections above are mandatory, not optional.

---

## 6. Quick reference

| Task | File(s) to touch | Test command |
|------|------------------|--------------|
| Add one skill | `skills/<name>/` + README | `node bin/install.js --<name> --no-plugins --dir=/tmp/t` |
| Add a skill bundle | `skills/<many>/` + `groups.json` + README | `node bin/install.js --<bundle> --no-plugins --dir=/tmp/t` |
| Add a plugin | `plugins.json` + README | `node bin/install.js --plugins-only` |
