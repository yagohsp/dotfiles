return {
    {
        "dundalek/lazy-lsp.nvim",
        dependencies = {
            {
                "neovim/nvim-lspconfig",
                lazy = false,
                config = function()
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
