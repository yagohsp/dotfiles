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
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local lspconfig = require("lspconfig")
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
            })
            lspconfig.html.setup({
                capabilities = capabilities,
            })
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })
            lspconfig.csharp_ls.setup({
                capabilities = capabilities,
            })

            vim.keymap.set(
                "n",
                "<leader>gd",
                vim.lsp.buf.definition,
                { desc = "Go to definition", noremap = true, silent = true }
            )
            vim.keymap.set(
                "n",
                "<leader>gr",
                vim.lsp.buf.references,
                { desc = "Go to references", noremap = true, silent = true }
            )
            vim.keymap.set(
                "n",
                "<leader>ca",
                vim.lsp.buf.code_action,
                { desc = "Execute code action", noremap = true, silent = true }
            )
        end,
    },
}
