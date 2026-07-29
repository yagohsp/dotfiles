return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = function()
          require("mason").setup({
            registries = {
              "github:crashdummyy/mason-registry",
              "github:mason-org/mason-registry",
            },
          })
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          auto_install = true,
        },
      },
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      mason_lspconfig.setup({
        ensure_installed = {
          "html",
          "eslint",
          "lua_ls",
          "omnisharp",
          "ts_ls",
        },
      })
    end,
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    lazy = true,
    module = "easy-dotnet",
    cmd = "Dotnet",
    ft = "cs",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>T",
        "<cmd>Dotnet testrunner<CR>",
        desc = "Dotnet Testrunner",
      },
    },
    config = function()
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
            refresh_testrunner = { lhs = "<C-r>", desc = "Refresh testrunner" },
          },
        },
      })
    end,
  },
}
