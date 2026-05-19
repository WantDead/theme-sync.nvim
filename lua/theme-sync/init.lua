local M = {}

---@class ThemeSyncOpts
---@field dark? string colorscheme name for dark mode
---@field light? string colorscheme name for light mode
---@field detect? fun(): "dark"|"light" custom OS detection override
---@field on_change? fun(mode: "dark"|"light") custom apply override
---@field poll_interval? integer ms between polls, 0 = disabled (default)

---@param opts? ThemeSyncOpts
M.setup = function(opts)
end

return M
