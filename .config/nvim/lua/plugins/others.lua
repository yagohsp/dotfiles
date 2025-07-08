return {
  "rcarriga/nvim-notify",
  "tpope/vim-surround",
  {
    "edluffy/hologram.nvim",
    config = function()
      require("hologram").setup({})
    end
  },
  {
    "abecodes/tabout.nvim",
    config = function()
      require('tabout').setup({
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' },
          { open = '<', close = '>' }
        },
      })
    end
  },
  {
    "ten3roberts/qf.nvim",
    config = function()
      require("qf").setup({})
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  },
  {
    'j-morano/buffer_manager.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local buffer_manager = require("buffer_manager.ui")
      vim.keymap.set("n", "<leader>B", function()
        buffer_manager.toggle_quick_menu()
      end, { noremap = true, silent = true, desc = "Open buffers manager" or "" })
    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},

  }
}
