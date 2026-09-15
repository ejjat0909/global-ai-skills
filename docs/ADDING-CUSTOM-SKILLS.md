# Adding a Custom Skill (public contributor guide)

This is the guide for contributing a **new custom skill you authored yourself**
(not copied from another repo — see `docs/ADDING-SKILLS-AND-PLUGINS.md` for
vendoring an existing skill/plugin from elsewhere). Same repo, same installer,
same rules — this doc is just the "I wrote this from scratch" path.

## 1. Decide it's actually a skill

A skill is a **reusable procedure** you'd otherwise repeat as a prompt every
time — a checklist, a workflow, a set of non-negotiable rules for a recurring
task. If you're pasting the same instructions to your AI agent more than once,
it's a skill.

## 2. Create the folder

```bash
mkdir -p skills/<your-skill-name>
```

- Name: lowercase, hyphenated, unique (`ls skills/ | grep -i <name>` first).
- One skill = one folder. Everything the skill needs lives under it
  (`SKILL.md` + optional `references/`, `scripts/`, `templates/`).

## 3. Write `SKILL.md`

Required shape:

```markdown
---
name: your-skill-name
description: Use when <trigger>. <one-line what it does>.
---

# Your Skill Title

Trigger: when to use this skill.

## Rules / Steps
...numbered, concrete steps or non-negotiable rules...

## What NOT to do
...explicit anti-goals, so the skill doesn't scope-creep...
```

Frontmatter `name` and `description` are **required** — CI checks for them.
`description` should state the trigger condition in one line (that's how an
agent decides to load it).

Write it the way you'd brief a competent contractor who's never seen your
codebase: concrete rules, not vibes. Prefer:

- Numbered checklists over paragraphs.
- Explicit "don't do X" lines for common overreach.
- Real command/code snippets where relevant, not pseudocode.

## 4. Test it

```bash
node -c bin/install.js && node bin/install.js --help > /dev/null && echo installer OK
node bin/install.js --help | grep -- "--<your-skill-name>" && echo "flag present"

rm -rf /tmp/test-skill
node bin/install.js --<your-skill-name> --no-plugins --dir=/tmp/test-skill
ls /tmp/test-skill/<your-skill-name>/SKILL.md
head -6 /tmp/test-skill/<your-skill-name>/SKILL.md   # confirm frontmatter present
```

## 5. Update README + push

Add a row to the **Available skills** table in `README.md`, then:

```bash
git add -A
git commit -m "Add <your-skill-name> skill: <one-line what it does>"
git push -u origin add-<your-skill-name>
```

Open a PR. CI (`.github/workflows/contribution-check.yml`) will verify the
folder/frontmatter shape automatically — see its output if it fails.

## Rules (do not violate)

- One skill = one folder, `SKILL.md` at its top level.
- Frontmatter must have `name` and `description`.
- No nested `.git`.
- Don't touch `bin/install.js` — folder name becomes the flag automatically.
- If it's a multi-folder bundle, see `docs/ADDING-SKILLS-AND-PLUGINS.md`
  section 2.6 for `groups.json`.
