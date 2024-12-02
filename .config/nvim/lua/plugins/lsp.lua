return {
    {
        "dundalek/lazy-lsp.nvim",
        dependencies = {
            {
                "neovim/nvim-lspconfig",
                lazy = false,
                config = function()
                    local opts = function(desc)
                        return { noremap = true, silent = true, desc = desc or "" }
                    end
                    vim.keymap.set(
                        "n",
                        "<leader>ld",
                        vim.lsp.buf.definition, opts("Go to definition")
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>la",
                        vim.lsp.buf.code_action,
                        opts("Execute code actions")
                    )
                    vim.keymap.set('n', 'lt', vim.lsp.buf.type_definition, opts("Go to type definition"))
                    vim.keymap.set('n', 'li', vim.lsp.buf.implementation, opts("Go to type implementation"))
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
                    vim.keymap.set('n', 'le', vim.diagnostic.open_float, opts("Show errors"))
                end,
            },
            { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local lsp_zero = require("lsp-zero")

            lsp_zero.on_attach(function(_, bufnr)
                -- see :help lsp-zero-keybindings to learn the available actions
                lsp_zero.default_keymaps({
                    buffer = bufnr,
                    preserve_mappings = false,
                })
            end)
            require("lazy-lsp").setup({})
        end,
    },
    -- {
    --     "williamboman/mason.nvim",
    --     lazy = false,
    --     config = function()
    --         require("mason").setup()
    --     end,
    -- },
    -- {
    --     "williamboman/mason-lspconfig.nvim",
    --     lazy = false,
    --     opts = {
    --         auto_install = true,
    --     },
    -- },
}
