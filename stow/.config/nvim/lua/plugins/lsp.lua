return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      mason_lspconfig.setup(
        {
          ensure_installed = {
            "emmet_language_server",
            "eslint",
            "html",
            "jsonls",
            "lua_ls",
            "omnisharp",
            "rust_analyzer",
            "tailwindcss",
            "ts_ls",
          },
        })
      -- require("roslyn").setup()
    end,
    dependencies = {
      -- "seblyng/roslyn.nvim",
      {
        'williamboman/mason.nvim',
        config = function()
          require('mason').setup({
            registries = {
              "github:crashdummyy/mason-registry",
              "github:mason-org/mason-registry"
            },
          })
        end,
      },
      {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
        opts = {
          auto_install = true
        }
      }
    }
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>T", "<cmd>:Dotnet testrunner<CR>",
        { noremap = true, silent = true, desc = "Dotnet Testrunner" })
      require("easy-dotnet").setup({
        lsp = {
          enabled = false,
          roslynator_enabled = false,
        },
        test_runner = {
          viewmode = "float",
          mappings = {
            run_test_from_buffer = { lhs = "<leader>tr", desc = "Run test from buffer" },
            debug_test_from_buffer = { lhs = "<leader>tt", desc = "Debug test from buffer" },
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
}
