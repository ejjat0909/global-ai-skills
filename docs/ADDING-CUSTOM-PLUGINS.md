# Adding a Custom Plugin (public contributor guide)

For a plugin you authored yourself — not wrapping an existing npm package (see
`docs/ADDING-SKILLS-AND-PLUGINS.md` section 3 for that). A custom plugin is
machine setup logic: symlinks, config scaffolding, local service registration —
anything beyond "copy some files" or "npm install -g something".

## Plugin types

`plugins.json` entries have a `type`. Two supported:

| type | What runs | Use for |
|------|-----------|---------|
| `npm` (default, `type` can be omitted) | `npm install -g <package>` | Published npm package with a CLI/MCP bin |
| `script` | `bash plugins/<name>/<script>` | Local machine setup (symlinks, dirs, config) |

## Adding a `script` plugin

1. Put your script under `plugins/<your-plugin-name>/`:

   ```bash
   mkdir -p plugins/<your-plugin-name>
   ```

   The script must be **idempotent** — safe to run every install and every
   `--update`, on a machine where it's already set up. Back up before
   overwriting real files/dirs (don't silently clobber user data).

2. Add an entry to `plugins.json`:

   ```json
   {
     "your-plugin-name": {
       "type": "script",
       "script": "your-plugin-name/setup.sh",
       "description": "One line: what it sets up on the user's machine",
       "source": "plugins/your-plugin-name/setup.sh"
     }
   }
   ```

   `script` is relative to the repo's `plugins/` directory.

3. Test:

   ```bash
   node -c bin/install.js && echo "installer OK"
   node bin/install.js --help | grep -A5 Plugins   # your plugin listed
   node bin/install.js --plugins-only              # your script actually runs
   node bin/install.js --plugins-only               # re-run: must still succeed cleanly
   ```

4. Add it to the **Plugins** table in README.md.

## Rules (same as npm plugins)

- Installer stays zero-dependency — a `script` plugin shells out via
  `spawnSync`, no new npm deps in `bin/install.js` itself.
- Credit what the script does and why in `plugins.json`'s `description`.
- Don't silently overwrite existing user files/directories — back them up
  first (see `plugins/shared-ai-memory/setup.sh` for the pattern: valid
  symlink → skip, real dir → move to `<path>.backup_<timestamp>` then link).
- No secrets/credentials in the script or its output.
