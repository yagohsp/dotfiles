return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    opts = {
      auto_install = true
    }
  },
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
            "csharp_ls",
            "rust_analyzer",
            "tailwindcss",
            "ts_ls",
            -- "eslint_d",
            -- "prettierd",
            -- "stylua",
            -- "csharpier",
            -- "htmlhint",
          },
        })

      mason_lspconfig.setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,
      })
    end
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
  },
}
