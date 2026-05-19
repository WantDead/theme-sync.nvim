# agents.md

Guidelines for AI agents working on this repo.

## Project

`theme-sync.nvim` is a Neovim plugin that automatically switches the colorscheme when the OS dark/light mode changes. It has no external Lua dependencies — only the Neovim standard library.

## Architecture

Four modules, each with a single responsibility:

| File | Role |
|------|------|
| `lua/theme-sync/init.lua` | Public API — `setup(opts)` validates opts, wires the other modules |
| `lua/theme-sync/detect.lua` | OS detection — returns `"dark"` or `"light"` |
| `lua/theme-sync/apply.lua` | Theme application — sets `vim.o.background` and/or calls colorscheme |
| `lua/theme-sync/trigger.lua` | Event wiring — startup run + `FocusGained` autocmd + optional poll timer |

Data flow: `trigger` → `detect` → `apply`. `init` owns `opts` and passes it down.

## Conventions

- No comments explaining what code does — names should be self-evident
- No error handling for impossible states; validate only at `setup()` entry point
- `io.popen` for shell commands (works during early Neovim init); `vim.fn.system` is fine inside autocmd callbacks
- Always use full binary paths in shell commands (e.g. `/usr/bin/defaults`) — plugin may load before `$PATH` is fully set
- `detect.lua` must never throw; always return a valid mode string
- `apply.lua` must be idempotent — calling it twice with the same mode is a no-op

## OS detection commands

| OS | Command | Dark signal |
|----|---------|-------------|
| macOS | `/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null` | output contains `"Dark"` |
| Linux/GNOME | `gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null` | output contains `"dark"` |
| Linux/KDE | `kreadconfig5 --group "General" --key "ColorScheme" 2>/dev/null` | output contains `"Dark"` |
| Windows | `powershell.exe -Command "Get-ItemProperty ... AppsUseLightTheme"` | value is `0` |

Light mode = the key/value does not exist or returns the light sentinel. Default fallback: `"dark"`.

## Testing

No test framework is set up yet. Manual testing steps:
1. Add plugin to a local Neovim config pointing at this repo path
2. Switch OS appearance, refocus Neovim, verify colorscheme changes
3. Restart Neovim in the opposite appearance, verify startup applies the right theme

## What not to do

- Do not hardcode theme names anywhere except `opts` defaults
- Do not couple `detect`, `apply`, or `trigger` to each other directly — route through `init`
- Do not call `vim.cmd.colorscheme` if `opts.on_change` is set — it takes full control
- Do not add NvChad / distro-specific code to core modules; that belongs in user config via `on_change`
