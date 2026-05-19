if vim.g.loaded_theme_sync then return end
vim.g.loaded_theme_sync = true

require("theme-sync").setup()
