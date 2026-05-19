local M = {}

---@return "dark"|"light"
local function macos()
  local handle = io.popen("/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not handle then return "dark" end
  local out = handle:read("*a")
  handle:close()
  return out:match("Dark") and "dark" or "light"
end

---@return "dark"|"light"
M.get = function()
  local os = jit.os
  if os == "OSX" then return macos() end
  return "dark"
end

return M
