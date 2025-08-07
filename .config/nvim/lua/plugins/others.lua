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
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
    config = function()
      vim.keymap.set("n", "<leader>T", "<cmd>:Dotnet testrunner<CR>",
        { noremap = true, silent = true, desc = "Dotnet Testrunner" })
      require("easy-dotnet").setup({
        test_runner = {
          viewmode = "float",
          mappings = {
            run_test_from_buffer = { lhs = "<leader>tr", desc = "Run test from buffer" },
            debug_test_from_buffer = { lhs = "<leader>td", desc = "Debug test from buffer" },
            filter_failed_tests = { lhs = "f", desc = "Filter failed tests" },
            debug_test = { lhs = "d", desc = "Debug test" },
            go_to_file = { lhs = "g", desc = "Go to file" },
            run_all = { lhs = "<leader>tR", desc = "Run all tests" },
            run = { lhs = "r", desc = "Run test" },
            peek_stacktrace = { lhs = "p", desc = "Peek stacktrace of failed test" },
            expand = { lhs = "<Enter>", desc = "Expand" },
            expand_all = { lhs = "a", desc = "Expand all" },
            collapse_all = { lhs = "A", desc = "Collapse all" },
            close = { lhs = "q", desc = "Close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "Refresh testrunner" }
          },
        }
      })

      vim.keymap.set("n", "<leader>d", "<cmd>bdelete!<CR>", { noremap = true, silent = true, desc = "Delete buffer" })
    end
  },
  -- nvim lsp
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
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
