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
            -- "omnisharp",
            "rust_analyzer",
            "tailwindcss",
            "ts_ls",
          },
        })
      require("roslyn").setup()
    end,
    dependencies = {
      "seblyng/roslyn.nvim",
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
  }
}
