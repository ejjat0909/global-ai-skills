#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const ROOT = path.join(__dirname, '..');
const SKILLS_DIR = path.join(ROOT, 'skills');

// Group flag -> skill folders under skills/. A flag not listed here maps to a
// single folder of the same name (e.g. --ui-ux-pro-max -> skills/ui-ux-pro-max).
const GROUPS = {
  'anti-slop': [
    'antislop',
    'antislop-code',
    'antislop-copywriting',
    'antislop-human',
    'antislop-layoutmobile',
    'antislop-ui',
  ],
};

function listSkillFolders() {
  return fs
    .readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter((d) => d.isDirectory() && fs.existsSync(path.join(SKILLS_DIR, d.name, 'SKILL.md')))
    .map((d) => d.name)
    .sort();
}

// The flags a user can pass: every group + every standalone (non-grouped) skill.
function availableFlags(folders) {
  const grouped = new Set(Object.values(GROUPS).flat());
  const flags = Object.keys(GROUPS);
  for (const f of folders) if (!grouped.has(f)) flags.push(f);
  return flags.sort();
}

function parseArgs(argv) {
  const args = { flags: [], project: false, dir: null, help: false, update: false };
  for (const arg of argv) {
    if (arg === '--help' || arg === '-h') args.help = true;
    else if (arg === '--update' || arg === '-u') args.update = true;
    else if (arg === '--all') args.flags.push('--all');
    else if (arg === '--project' || arg === '-p') args.project = true;
    else if (arg.startsWith('--dir=')) args.dir = arg.slice('--dir='.length);
    else if (arg.startsWith('--')) args.flags.push(arg.slice(2));
    else args.flags.push(arg);
  }
  return args;
}

function targetBase(args) {
  if (args.dir) return path.resolve(args.dir);
  if (args.project) return path.join(process.cwd(), '.claude', 'skills');
  return path.join(os.homedir(), '.claude', 'skills');
}

// Resolve requested flags into a deduped list of skill folders.
function resolveFolders(flags, folders) {
  const set = new Set();
  for (const flag of flags) {
    if (GROUPS[flag]) GROUPS[flag].forEach((f) => set.add(f));
    else if (folders.includes(flag)) set.add(flag);
    else throw new Error(`Unknown skill or group: --${flag}`);
  }
  return [...set];
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(s, d);
    else fs.copyFileSync(s, d);
  }
}

function install(folder, base) {
  const src = path.join(SKILLS_DIR, folder);
  const dest = path.join(base, folder);
  fs.rmSync(dest, { recursive: true, force: true }); // clean copy: drop stale files
  copyDir(src, dest);
  console.log(`Installed "${folder}" -> ${dest}`);
}

// Skills already present in the target dir (a folder with a SKILL.md that we ship).
function installedFolders(base, folders) {
  if (!fs.existsSync(base)) return [];
  return folders.filter((f) => fs.existsSync(path.join(base, f, 'SKILL.md')));
}

function printHelp(flags) {
  console.log(`global-ai-skills — install AI agent skills with one command

Usage:
  npx github:ejjat0909/global-ai-skills [--skill ...] [options]

Install all skills (default when no skill flag given):
  npx github:ejjat0909/global-ai-skills
  npx github:ejjat0909/global-ai-skills --all

Install specific skills:
${flags.map((f) => `  --${f}`).join('\n')}

Options:
  --update, -u   Refresh already-installed skills to the latest version
  --project      Install to ./.claude/skills instead of ~/.claude/skills
  --dir=<path>   Install to a custom directory
  -h, --help     Show this help

Examples:
  npx github:ejjat0909/global-ai-skills --anti-slop
  npx github:ejjat0909/global-ai-skills --anti-slop --ui-ux-pro-max
  npx github:ejjat0909/global-ai-skills --mobile-app-setup --project
  npx github:ejjat0909/global-ai-skills --update
  npx github:ejjat0909/global-ai-skills --update --anti-slop
`);
}

function main() {
  const folders = listSkillFolders();
  const flags = availableFlags(folders);
  const args = parseArgs(process.argv.slice(2));

  if (args.help) return printHelp(flags);

  const base = targetBase(args);
  const requested = args.flags.filter((f) => f !== '--all');

  let targets;

  if (args.update) {
    // Update mode: refresh only skills already present in the target dir.
    // With skill flags, update just those (that are installed); without, update all installed.
    let candidates;
    try {
      candidates = requested.length ? resolveFolders(requested, folders) : folders;
    } catch (e) {
      console.error(e.message);
      process.exit(1);
    }
    const installed = installedFolders(base, folders);
    targets = candidates.filter((f) => installed.includes(f));
    if (targets.length === 0) {
      console.log(`Nothing to update — no matching skills installed in ${base}`);
      return;
    }
    fs.mkdirSync(base, { recursive: true });
    for (const t of targets) install(t, base);
    console.log(`\nUpdated ${targets.length} skill folder(s) in ${base}`);
    return;
  }

  const installAll = args.flags.includes('--all') || requested.length === 0;

  try {
    targets = installAll ? folders : resolveFolders(requested, folders);
  } catch (e) {
    console.error(e.message);
    console.error(`\nAvailable: ${flags.map((f) => '--' + f).join(', ')}`);
    process.exit(1);
  }

  fs.mkdirSync(base, { recursive: true });
  for (const t of targets) install(t, base);
  console.log(`\nDone. ${targets.length} skill folder(s) installed to ${base}`);
}

main();
