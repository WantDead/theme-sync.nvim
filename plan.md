# plan.md

Implementation plan for `theme-sync.nvim`.

## Phase 1 — Detection (`detect.lua`)

Implement `M.get()`:

1. Detect OS via `jit.os` (`"Windows"`, `"OSX"`, `"Linux"`)
2. Run the corresponding shell command with `io.popen`
3. Parse stdout and return `"dark"` or `"light"`
4. On any failure (nil handle, empty output, unknown OS) return `"dark"`

OS commands:
- macOS: `/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null` → contains `"Dark"`
- Linux: try `gsettings` first, fall back to `kreadconfig5`
- Windows: `powershell.exe -NoProfile -Command "(Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize).AppsUseLightTheme"` → `0` = dark

Acceptance: `require("theme-sync.detect").get()` returns the correct mode on each OS.

---

## Phase 2 — Apply (`apply.lua`)

Implement `M.set(mode, opts)`:

1. If `opts.on_change` is set → call it with `mode` and return (full user control)
2. Set `vim.o.background = mode` (covers most colorschemes)
3. If `opts.dark` / `opts.light` is set → call `vim.cmd.colorscheme(opts[mode])` after background

Guard: skip if `vim.o.background` already equals `mode` AND no explicit colorscheme pair is configured (pure background setups are already correct after step 2).

Acceptance: calling `M.set("light", opts)` switches the visible theme; calling it again with the same mode is a no-op.

---

## Phase 3 — Trigger (`trigger.lua`)

Implement `M.init(opts)`:

1. **Startup**: call `detect` + `apply` immediately (synchronously, before first render)
2. **FocusGained**: create autocmd that calls `detect` + `apply` on every focus event
3. **Poll** (optional): if `opts.poll_interval > 0`, start a `vim.uv.new_timer` that calls `detect` + `apply` on the given interval

The timer should be stored in a module-level variable so it can be stopped cleanly if needed.

Acceptance: switching OS appearance, alt-tabbing back to Neovim, and seeing the theme change within one focus event.

---

## Phase 4 — Setup (`init.lua`)

Implement `M.setup(opts)`:

1. Merge user opts with defaults (`poll_interval = 0`, everything else nil)
2. Validate: if `dark` or `light` is set, both must be set; warn via `vim.notify` if only one is provided
3. Call `require("theme-sync.trigger").init(opts)`

Guard: `setup()` should be idempotent — calling it twice should not register duplicate autocmds or timers. Use a module-level `_initialized` flag.

Acceptance: `require("theme-sync").setup({})` works without errors on a vanilla Neovim install with no opts.

---

## Phase 5 — Health check

Add `:checkhealth theme-sync`:

- Detected OS
- Current mode returned by `detect.get()`
- Whether `on_change` override is active
- Whether poll timer is running

File: `lua/theme-sync/health.lua`, registered in `init.lua` via `vim.health`.

---

## Phase 6 — Docs + README

- Fill in `doc/theme-sync.txt` with full vimdoc
- Update README with correct GitHub username once repo is published
- Add install examples for lazy.nvim, rocks.nvim

---

## Out of scope (for now)

- Wayland-specific detection
- Tmux / terminal multiplexer passthrough
- GUI clients (Neovide, etc.)
- Per-filetype or per-window theme overrides
