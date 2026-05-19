local M = {}

---@class ThemeSyncOpts
---@field dark? string colorscheme name for dark mode
---@field light? string colorscheme name for light mode
---@field detect? fun(): "dark"|"light" custom OS detection override
---@field on_change? fun(mode: "dark"|"light") custom apply override
---@field poll_interval? integer ms between polls, 0 = disabled (default)

local _initialized = false
M._opts = nil

---@param opts? ThemeSyncOpts
M.setup = function(opts)
  if _initialized then return end
  _initialized = true

  opts = vim.tbl_extend("force", { poll_interval = 0 }, opts or {})
  M._opts = opts

  if (opts.dark == nil) ~= (opts.light == nil) then
    vim.notify("theme-sync: set both 'dark' and 'light', or neither", vim.log.levels.WARN)
  end

  if opts.detect then
    local detect = require("theme-sync.detect")
    local orig = detect.get
    detect.get = function()
      return opts.detect() or orig()
    end
  end

  require("theme-sync.trigger").init(opts)
end

vim.api.nvim_create_user_command("ThemeSyncHealth", function()
  vim.cmd("checkhealth theme-sync")
end, {})

return M
