local M = {}

M.check = function()
  local health = vim.health

  health.start("theme-sync")

  -- OS
  local os = jit.os
  if os == "OSX" or os == "Linux" then
    health.ok("OS: " .. os)
  else
    health.warn("OS: " .. os .. " (unsupported, defaulting to dark)")
  end

  -- current mode
  local ok, detect = pcall(require, "theme-sync.detect")
  if ok then
    local mode = detect.get()
    health.ok("Detected mode: " .. mode)
  else
    health.error("theme-sync.detect failed to load")
  end

  -- apply state
  local ok2, apply = pcall(require, "theme-sync.apply")
  if ok2 and apply.current() then
    health.ok("Active mode: " .. apply.current())
  else
    health.warn("No mode applied yet (plugin not set up?)")
  end

  -- on_change override
  local ok3, init = pcall(require, "theme-sync")
  if ok3 and init._opts then
    if init._opts.on_change then
      health.ok("Backend: custom on_change override")
    elseif init._opts.dark then
      health.ok("Backend: colorscheme pair (" .. init._opts.dark .. " / " .. init._opts.light .. ")")
    else
      health.ok("Backend: vim.o.background only")
    end

    local interval = init._opts.poll_interval or 0
    if interval > 0 then
      health.ok("Poll timer: every " .. interval .. "ms")
    else
      health.ok("Poll timer: disabled")
    end
  else
    health.warn("setup() has not been called")
  end
end

return M
