# CLAUDE.md

## Project

`theme-sync.nvim` is a Neovim plugin that automatically switches the colorscheme when the OS dark/light mode changes. No external Lua dependencies — Neovim stdlib only.

**Scope: macOS and Linux only.** Windows support is out of scope.

## Architecture

Four modules, single responsibility each:

| File | Role |
|------|------|
| `lua/theme-sync/init.lua` | Public API — `setup(opts)`, validates, wires modules |
| `lua/theme-sync/detect.lua` | OS detection — returns `"dark"` or `"light"` |
| `lua/theme-sync/apply.lua` | Theme application — sets `vim.o.background` and/or colorscheme |
| `lua/theme-sync/trigger.lua` | Event wiring — startup + `FocusGained` autocmd + optional poll timer |

Data flow: `trigger` → `detect` → `apply`. `init` owns `opts` and passes it down.

## Conventions

- No comments unless the WHY is non-obvious
- No error handling for impossible states — validate at `setup()` only
- Use `io.popen` for shell commands in `detect.lua` (safe during early Neovim init)
- Always use full binary paths in shell commands — plugin may load before `$PATH` is set
- `detect.lua` must never throw — always return a valid mode string, default `"dark"`
- `apply.lua` must be idempotent — same mode twice is a no-op

## OS Detection

| OS | Command | Dark signal |
|----|---------|-------------|
| macOS | `/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null` | output contains `"Dark"` |
| Linux/GNOME | `gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null` | output contains `"dark"` |
| Linux/KDE | `kreadconfig5 --group "General" --key "ColorScheme" 2>/dev/null` | output contains `"Dark"` |

Light mode on macOS = key does not exist → empty stdout. Default fallback: `"dark"`.

## Testing

No test framework. Manual steps:
1. Point a local Neovim config at this repo (`dev = true` in lazy.nvim)
2. Switch OS appearance, refocus Neovim — verify theme changes
3. Restart Neovim in opposite appearance — verify startup applies correct theme

## Do Not

- Hardcode theme names anywhere outside `opts`
- Couple `detect`, `apply`, or `trigger` to each other — route through `init`
- Call `vim.cmd.colorscheme` when `opts.on_change` is set — it owns apply entirely
- Add NvChad or distro-specific code to core modules — that belongs in user config via `on_change`
- Add Windows support
