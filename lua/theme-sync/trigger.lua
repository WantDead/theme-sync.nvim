local M = {}

local timer = nil

---@param opts ThemeSyncOpts
M.init = function(opts)
  local detect = require("theme-sync.detect")
  local apply  = require("theme-sync.apply")

  apply.set(detect.get(), opts)

  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("ThemeSync", { clear = true }),
    callback = function()
      apply.set(detect.get(), opts)
    end,
  })

  if opts.poll_interval and opts.poll_interval > 0 then
    timer = vim.uv.new_timer()
    timer:start(opts.poll_interval, opts.poll_interval, vim.schedule_wrap(function()
      apply.set(detect.get(), opts)
    end))
  end
end

M.stop = function()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

return M
