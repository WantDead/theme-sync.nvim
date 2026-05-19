local M = {}

local _mode = nil

---@return "dark"|"light"|nil
M.current = function()
  return _mode
end

---@param mode "dark"|"light"
---@param opts ThemeSyncOpts
M.set = function(mode, opts)
  _mode = mode
  if opts.on_change then
    opts.on_change(mode)
    return
  end

  if vim.o.background == mode and not opts[mode] then return end

  vim.o.background = mode

  if opts[mode] then
    vim.cmd.colorscheme(opts[mode])
  end
end

return M
