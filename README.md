# theme-sync.nvim

Automatically syncs your Neovim colorscheme with the OS dark/light mode.
Works on macOS, Linux (GNOME, KDE) with no external dependencies.

## Install

**lazy.nvim**
```lua
{
  "WantDead/theme-sync.nvim",
  opts = {
    dark  = "tokyonight-night",
    light = "tokyonight-day",
  },
}
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
