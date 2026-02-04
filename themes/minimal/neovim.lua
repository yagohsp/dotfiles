return {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  name = "catppuccin",
  config = function()
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}

-- return {
--   'sainnhe/gruvbox-material',
--   lazy = false,
--   priority = 1000,
--   config = function()
--     -- Optionally configure and load the colorscheme
--     -- directly inside the plugin declaration.
--     vim.o.background = "light"
--     vim.g.gruvbox_material_background = 'soft'
--     vim.g.gruvbox_material_enable_italic = true
--     vim.cmd.colorscheme('gruvbox-material')
--   end
-- }
