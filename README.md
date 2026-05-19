# theme-sync.nvim

Automatically syncs your Neovim colorscheme with the OS dark/light mode.
Works on macOS, Linux (GNOME, KDE) with no external dependencies.

## Install

**lazy.nvim**
```lua
{
  "WantDead/theme-sync.nvim",
  lazy = false,
  opts = {
    dark  = "tokyonight",
    light = "tokyonight-day",
  },
}
```

**mini.deps**
```lua
require("mini.deps").add("WantDead/theme-sync.nvim")
require("theme-sync").setup({ dark = "tokyonight", light = "tokyonight-day" })
```

**vim.pack / built-in packages**
```bash
git clone https://github.com/WantDead/theme-sync.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/theme-sync.nvim
```

The plugin auto-loads with default settings (background-only sync). To configure a colorscheme pair, add this to your `init.lua`:
```lua
require("theme-sync").setup({ dark = "tokyonight", light = "tokyonight-day" })
```

## Options

| Key             | Type                          | Default | Description                              |
|----------------|-------------------------------|---------|------------------------------------------|
| `dark`          | `string`                      | `nil`   | Colorscheme for dark mode                |
| `light`         | `string`                      | `nil`   | Colorscheme for light mode               |
| `detect`        | `fun(): "dark"\|"light"`      | `nil`   | Custom detection override                |
| `on_change`     | `fun(mode: "dark"\|"light")`  | `nil`   | Custom apply override                    |
| `poll_interval` | `integer` (ms)                | `0`     | Poll interval, `0` = disabled            |

## Health check

```
:checkhealth theme-sync
```

Reports detected OS, current mode, active backend, and poll timer status.

## NvChad

Use `on_change` to hook into base46:

```lua
require("theme-sync").setup({
  on_change = function(mode)
    require("nvconfig").base46.theme = mode == "dark" and "github_dark" or "github_light"
    require("base46").load_all_highlights()
  end,
})
```
