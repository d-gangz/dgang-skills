# Plugins Guide (for Claude)

This reference helps you (the agent) guide the user through installing a Claude Code plugin. Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSPs, distributed via marketplaces.

## What you can do vs. what the user does

| Action | Who |
|---|---|
| Suggest plugins (browse `claude.com/plugins` or marketplace via WebFetch) | You |
| For LSP plugins: pre-flight check the required binary is on PATH | You via Bash |
| Type `/plugin` and navigate the TUI (Tab, arrows, Enter) | **User** |
| Pick scope (User / Project / Local) at the TUI prompt | **User** answers Claude Code's own prompt |
| Type `/reload-plugins` after install | **User** |
| Verify the plugin loaded | You via Bash + Read |

**Why the TUI is the primary path:** the user picks scope themselves at the TUI prompt, instead of getting silently defaulted to user scope (which is what `/plugin install X@Y` does on its own). The trade-off is a few keystrokes; the upside is the user understands and chooses where the plugin lives.

Your job: pick the plugin together, pre-flight any binary requirements, walk the user through the TUI, then verify after.

## Two cases: official vs. external

The flow differs at the start depending on where the plugin lives:

| Where the plugin lives | What needs to happen first |
|---|---|
| **Official marketplace** (`claude-plugins-official`) | Auto-loaded. Skip straight to the install TUI. |
| **External / community marketplace** (any GitHub repo, GitLab, etc.) | User must add the marketplace first via the TUI. The marketplace's `owner/repo` comes from the plugin's GitHub URL. |

Browse the official catalog at `claude.com/plugins`. For external plugins the user typically links you to a GitHub README that includes the install commands.

## Procedure

### Step 1 — Identify the plugin and marketplace

**If from the official marketplace:** the marketplace name is `claude-plugins-official` (already loaded). Plugin name is whatever the user picked — e.g. `commit-commands`, `pyright-lsp`. Skip to Step 2.

**If external:** you need two things from the plugin's GitHub README:

1. The **marketplace source** — the GitHub `owner/repo` to add. This is just the URL path. Example:
   - URL `https://github.com/EveryInc/compound-knowledge-plugin` → marketplace source `EveryInc/compound-knowledge-plugin`
2. The **plugin name** to install from inside that marketplace — usually shown in the README's install snippet, e.g. `compound-knowledge`. Plugin name is *not* always the same as the repo name; check the README.

If the user gave you a GitHub URL, fetch the README via `gh api` to confirm both:

```bash
gh api repos/<owner>/<repo>/contents/README.md --jq '.content' | base64 -d | head -100
```

Look for the `/plugin marketplace add ...` and `/plugin install ...` lines — those tell you the exact strings.

**Help picking a plugin (no specific one in mind):**

- Official catalog: `claude.com/plugins` (WebFetch).
- Common official-marketplace plugins worth knowing:
  - **Code intelligence (LSP):** `typescript-lsp`, `pyright-lsp`, `gopls-lsp`, `rust-analyzer-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp` — give Claude jump-to-definition, auto-diagnostics, and type info after edits.
  - **Source control:** `github`, `gitlab`
  - **Project management:** `atlassian` (Jira/Confluence), `asana`, `linear`, `notion`
  - **Design:** `figma`
  - **Infrastructure:** `vercel`, `firebase`, `supabase`
  - **Communication:** `slack`
  - **Monitoring:** `sentry`
  - **Workflows:** `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`
  - **Output styles:** `explanatory-output-style`, `learning-output-style`

### Step 2 — Pre-flight (LSP plugins only)

LSP plugins require the language server binary to already be on the user's PATH. Check via Bash before walking them through the install:

| Plugin | Binary to check |
|---|---|
| `clangd-lsp` | `clangd` |
| `csharp-lsp` | `csharp-ls` |
| `gopls-lsp` | `gopls` |
| `jdtls-lsp` | `jdtls` |
| `kotlin-lsp` | `kotlin-language-server` |
| `lua-lsp` | `lua-language-server` |
| `php-lsp` | `intelephense` |
| `pyright-lsp` | `pyright-langserver` |
| `rust-analyzer-lsp` | `rust-analyzer` |
| `swift-lsp` | `sourcekit-lsp` |
| `typescript-lsp` | `typescript-language-server` |

```bash
which <binary>
```

If missing, offer to install it (UAC/sudo caveat applies — hand off if interactive). Otherwise the plugin will install but show `Executable not found in $PATH` in the TUI's Errors tab.

For non-LSP plugins, skip this step.

### Step 3 — Walk the user through the TUI

#### Step 3a — Add the marketplace (external plugins only)

Skip this if the plugin is from `claude-plugins-official`.

Tell the user, one keystroke per step:

1. Type `/plugin` and press **Enter**. The Plugin Manager opens.
2. Press **Tab** until the **Marketplaces** tab is highlighted.
3. Select **Add marketplace** (arrow keys + **Enter**).
4. Type the marketplace source: `<owner>/<repo>` (give them the exact string from Step 1).
5. Press **Enter**. Claude Code downloads the marketplace catalog.
6. The marketplace now appears in the list. Continue to Step 3b in the same TUI session.

> If they prefer a one-liner instead of the TUI flow above for adding the marketplace, they can exit the TUI (**Esc**) and type:
>
> ```
> /plugin marketplace add <owner>/<repo>
> ```
>
> Then re-open `/plugin` for the install step. Same outcome.

#### Step 3b — Install the plugin

1. Press **Tab** until the **Discover** tab is highlighted.
2. **Arrow keys** to find the plugin (`<plugin-name>`), **Enter** to view it.
3. Press **Enter** again to install. A scope picker appears.
4. Pick scope:
   - **User scope** — installed for you across all projects
   - **Project scope** — installed for everyone on this repo (committed via git)
   - **Local scope** — just you, just this repo (not committed)
5. Confirm with **Enter**.

> A fourth status, **Managed**, may appear on plugins in the **Installed** tab — these were installed by an admin via managed settings and the user can't modify them. It's not a pick option, just a label.

The TUI tabs (for context if they get lost):
- **Discover** — browse marketplace plugins
- **Installed** — manage what's installed (favorite with `f`, filter by typing, Enter for detail/disable/uninstall)
- **Marketplaces** — add / remove / update / toggle auto-update
- **Errors** — view loading errors (LSP binary missing, etc.)

### Step 4 — User reloads plugins

```
/reload-plugins
```

Claude Code will report counts (skills, agents, hooks, MCP servers, LSP servers) — confirms the plugin loaded.

### Step 5 — Verify (you)

Check the plugin registered in the right scope:

```bash
# User scope
jq '.enabledPlugins // empty' ~/.claude/settings.json

# Project scope
jq '.enabledPlugins // empty' .claude/settings.json

# Local scope
jq '.enabledPlugins // empty' .claude/settings.local.json
```

If the plugin reports `Executable not found` in the TUI Errors tab (LSP only), Step 2's binary check missed something — install it and have the user run `/reload-plugins`.

## Using installed plugins

Plugin skills appear as namespaced slash commands: `/<plugin-name>:<skill-name>`. For example, after installing `commit-commands`: `/commit-commands:commit`.

LSP plugins don't add slash commands — they work in the background, giving Claude diagnostics and code navigation. The user can press **Ctrl+O** to see inline diagnostics when "diagnostics found" appears.

## Marketplace source formats

Step 3a covers the typical case: a GitHub `owner/repo` source (which is just the path from the GitHub URL). The TUI's "Add marketplace" prompt accepts other source types too:

| Source type | Example string to type |
|---|---|
| GitHub repo | `EveryInc/compound-knowledge-plugin` |
| Other Git host (HTTPS) | `https://gitlab.com/company/plugins.git` |
| Other Git host (SSH) | `git@gitlab.com:company/plugins.git` |
| Specific branch / tag | append `#<ref>` — `https://gitlab.com/company/plugins.git#v1.0.0` |
| Local directory | `./my-marketplace` (must contain `.claude-plugin/marketplace.json`) |
| Remote `marketplace.json` URL | `https://example.com/marketplace.json` |

**Shortcuts** (anywhere a slash command is typed): `/plugin market` works as `/plugin marketplace`; `rm` works as `remove`.

> ⚠️ **Trust check.** Marketplaces and plugins execute arbitrary code on the user's machine with their privileges. Confirm the user trusts the source — particularly for non-GitHub Git hosts and remote URLs — before adding it. Anthropic doesn't vet third-party plugin contents.

## Auto-updates

- **Official marketplaces** (`claude-plugins-official`) — auto-update on by default.
- **Third-party / local marketplaces** — auto-update off by default.

To toggle: `/plugin` → **Marketplaces** tab → select marketplace → **Enable / Disable auto-update**.

To kill auto-updates entirely (Claude Code + plugins), set the `DISABLE_AUTOUPDATER` env var. To keep plugin auto-updates while disabling Claude Code's, set both `DISABLE_AUTOUPDATER=1` and `FORCE_AUTOUPDATE_PLUGINS=1`.

## Plugin slash commands (reference)

The user types these — you don't. Listed for context when troubleshooting:

| Command | What it does |
|---|---|
| `/plugin` | Open the Plugin Manager TUI |
| `/plugin install <name>@<marketplace>` | Direct install (defaults to user scope) |
| `/plugin uninstall <name>@<marketplace>` | Remove a plugin |
| `/plugin enable / disable <name>@<marketplace>` | Toggle without removing |
| `/plugin marketplace add <source>` | Add a marketplace |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh a marketplace's plugin list |
| `/plugin marketplace remove <name>` | Remove a marketplace (uninstalls its plugins) |
| `/reload-plugins` | Apply plugin changes without restarting |

## Team marketplaces

Admins can pre-configure marketplaces for a project via `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

When team members trust the repo folder, Claude Code prompts them to install. You can edit this file directly via Edit when an admin asks you to set this up.

## Troubleshooting

### "/plugin command not recognized"

Their Claude Code version is too old. Tell the user to upgrade:

- **Homebrew:** `brew upgrade claude-code` (or `brew upgrade claude-code@latest` if they installed that cask)
- **npm:** `npm update -g @anthropic-ai/claude-code`
- **Native installer:** rerun the install command from `https://code.claude.com/docs/en/setup`

Then restart Claude Code (`claude --version` to confirm the new version).

### "Plugin not found in any marketplace"

The marketplace is missing or stale. For the official marketplace:

```
/plugin marketplace update claude-plugins-official
```

If that fails because the marketplace isn't there at all:

```
/plugin marketplace add anthropics/claude-plugins-official
```

(The user types these.)

### Plugin installed but skills don't appear

1. Did they run `/reload-plugins`?
2. Have them restart Claude Code completely (`/exit`, then `claude`).
3. Check the TUI **Errors** tab — `/plugin` → Errors. LSP plugins commonly show up here if their binary isn't on PATH.
4. As a last resort, clear the plugin cache via Bash (confirm with the user first):

   ```bash
   rm -rf ~/.claude/plugins/cache
   ```

   Then they restart Claude Code and reinstall.

### LSP plugin showing `Executable not found in $PATH`

The language server binary isn't installed. Look up the required binary in the table in Step 2 and install it. After install, have the user run `/reload-plugins`.

### High memory usage from an LSP plugin

`rust-analyzer` and `pyright` can use a lot of memory on big repos. The user can disable that plugin: `/plugin disable <plugin-name>@claude-plugins-official` — Claude falls back to its built-in search tools.

### Files-not-found errors after install

Plugins are copied to a cache, so paths inside the plugin that reference files *outside* the plugin directory won't resolve. This is a plugin authoring issue — direct the user to the plugin's repo.

## Resources

- **Online catalog:** `https://claude.com/plugins`
- **Official docs:** `https://code.claude.com/docs/en/plugins`
- **Plugin reference (for authors):** `https://code.claude.com/docs/en/plugins-reference`
