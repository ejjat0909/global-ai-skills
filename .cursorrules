# AGENTS.md — instructions for AI agents working in this repo

This repository is `global-ai-skills`: a one-command installer that gives an AI
agent a bundle of skills and plugins.

## MANDATORY: before adding a skill or plugin

If your task is to **add, update, or remove a skill or a plugin** (or to change
how the installer bundles them), you MUST first read this document in full and
follow it exactly:

    docs/ADDING-SKILLS-AND-PLUGINS.md

That guide is the authoritative, step-by-step procedure (A–Z) including the
required testing commands. Do not improvise an approach, do not guess the repo
layout, and do not skip the testing sections — the guide covers all of it.

Writing a brand-new skill from scratch (not vendored from elsewhere)? Use
`docs/ADDING-CUSTOM-SKILLS.md` instead — same repo/installer rules, focused on
authoring `SKILL.md` frontmatter and content.

Writing a brand-new plugin from scratch (a local setup script, not an npm
package)? Use `docs/ADDING-CUSTOM-PLUGINS.md` — covers `plugins.json`'s
`type: "script"` shape and the idempotency requirement.

## Fast facts (the guide has the full detail)

- Skills are folders under `skills/` containing a `SKILL.md`. The folder name
  becomes the install flag automatically.
- Skill bundles (one flag → many folders) are declared in `groups.json`.
- Plugins are published npm packages referenced in `plugins.json` — never
  vendor a plugin's source into `skills/`.
- The installer is `bin/install.js`, a zero-dependency Node script. Keep it
  dependency-free.
- Never commit a nested `.git`. Always update the relevant README table.

## Definition of done

A contribution is complete only when the testing commands in
`docs/ADDING-SKILLS-AND-PLUGINS.md` (sections 2.7 for skills, 3.3 for plugins,
and the section 4 final checklist) all pass.
