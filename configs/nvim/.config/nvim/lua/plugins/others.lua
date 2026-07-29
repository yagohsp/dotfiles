return {
  {
    "abecodes/tabout.nvim",
    config = function()
      require("tabout").setup({
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = "`", close = "`" },
          { open = "(", close = ")" },
          { open = "[", close = "]" },
          { open = "{", close = "}" },
          { open = "<", close = ">" },
        },
      })
    end,
  },
  {
    "ten3roberts/qf.nvim",
    config = function()
      require("qf").setup({})
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ---@module "render-markdown"
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "atiladefreitas/lazyclip",
    config = function()
      vim.keymap.set(
        { "n", "v", "i" },
        "<A-p>",
        ":lua require('lazyclip.ui').open_window()<CR>",
        { noremap = true, silent = true, desc = "Open Clipboard Manager" }
      )

      require("lazyclip").setup({
        disable_default_keymap = true,
        keymaps = {
          close_window = "<ESC>",
        },
      })
    end,
  },
  {
    "nvim-java/nvim-java",
    ft = { "java" },
    config = function()
      require("java").setup()
      vim.lsp.enable("jdtls")
    end,
  },
}
