-- LazyVim plugin spec for dotnet_functions.nvim
-- Put this file in: ~/.config/nvim/lua/plugins/dotnet_functions.lua
--
-- Replace "yourname/dotnet_functions.nvim" with the real GitHub repo if you publish it.
-- If you are developing locally, see the 'local dev' example below (commented).

return {
  -- {
  --   "yourname/dotnet_functions.nvim", -- change to e.g. "yagohsp/dotnet_functions.nvim" if you push it to GitHub
  --   lazy = false,                     -- load eagerly (you can set `true` to lazy-load)
  --   ft = { "cs", "csharp", "fsharp" },-- optional: only load for these filetypes
  --   dependencies = {
  --     "neovim/nvim-lspconfig",        -- for LSP (make sure you have OmniSharp or another C# LSP)
  --     "nvim-treesitter/nvim-treesitter", -- optional fallback
  --     -- "nvim-telescope/telescope.nvim", -- optional, only if you add Telescope integration later
  --   },
  --   config = function()
  --     -- no plugin options required; the module exposes :DotnetFunctions
  --     -- add a global mapping (in case the buffer-local autocmd mapping didn't trigger for you)
  --     vim.keymap.set("n", "<leader>df", "<cmd>DotnetFunctions<CR>", { desc = "Dotnet Functions" })
  --   end,
  -- },

  -- Local development example: uncomment and edit `dir` if you are developing locally
  {
    dir = "~/.config/nvim/my_plugins/dotnet_functions.nvim", -- local path to plugin
    lazy = false,
    ft = { "cs", "csharp", "fsharp" },
    config = function()
      vim.keymap.set("n", "<leader>ff", "<cmd>DotnetFunctions<CR>", { desc = "Dotnet Functions" })
    end,
  },
}
