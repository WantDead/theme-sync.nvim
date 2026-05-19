if vim.g.loaded_theme_sync then return end
vim.g.loaded_theme_sync = true

-- Deferred so plugin managers (lazy, mini.deps) can call setup() with opts first.
-- If nobody calls setup() by VimEnter, run with defaults.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("theme-sync").setup()
  end,
})
