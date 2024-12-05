return {
    {
        "dundalek/lazy-lsp.nvim",
        dependencies = {
            {
                "neovim/nvim-lspconfig",
                lazy = false,
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
}
