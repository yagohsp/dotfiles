return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            mason_lspconfig.setup({
                ensure_installed = {
                    "emmet-language-server",
                    "eslint-lsp",
                    "eslint_d",
                    "html-lsp",
                    "htmlhint",
                    "json-lsp",
                    "lua-language-server",
                    "csharp_ls",
                    "csharpier",
                    "prettierd",
                    "rust-analyzer",
                    "stylua",
                    "tailwindcss-language-server",
                    "typescript-language-server",
                },
            })

            mason_lspconfig.setup_handlers({
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                    })
                end,
            })

            for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
                local default_diagnostic_handler = vim.lsp.handlers[method]
                vim.lsp.handlers[method] = function(err, result, context, config)
                    if err ~= nil and err.code == -32802 then
                        return
                    end
                    return default_diagnostic_handler(err, result, context, config)
                end
            end
        end,
    },
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
}
