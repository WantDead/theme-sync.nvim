local M = {}

---@param cmd string
---@return string
local function shell(cmd)
  local handle = io.popen(cmd .. " 2>/dev/null")
  if not handle then return "" end
  local out = handle:read("*a")
  handle:close()
  return out or ""
end

---@return "dark"|"light"
local function macos()
  return shell("/usr/bin/defaults read -g AppleInterfaceStyle"):match("Dark") and "dark" or "light"
end

---@return "dark"|"light"|nil
local function gnome()
  local out = shell("gsettings get org.gnome.desktop.interface color-scheme")
  if out == "" then return nil end
  return out:match("dark") and "dark" or "light"
end

---@return "dark"|"light"|nil
local function kde()
  local out = shell("kreadconfig5 --group General --key ColorScheme --file kdeglobals")
  if out == "" then return nil end
  return out:match("Dark") and "dark" or "light"
end

---@return "dark"|"light"
local function linux()
  return gnome() or kde() or "dark"
end

---@return "dark"|"light"
M.get = function()
  local os = jit.os
  if os == "OSX"   then return macos() end
  if os == "Linux" then return linux() end
  return "dark"
end

return M
