-- return {
--     {
--         "dundalek/lazy-lsp.nvim",
--         dependencies = {
--             {
--                 "neovim/nvim-lspconfig",
--                 lazy = false,
--             },
--             { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
--             "hrsh7th/cmp-nvim-lsp",
--             "hrsh7th/nvim-cmp",
--         },
--         config = function()
--             local lsp_zero = require("lsp-zero")

--             lsp_zero.on_attach(function(_, bufnr)
--                 -- see :help lsp-zero-keybindings to learn the available actions
--                 lsp_zero.default_keymaps({
--                     buffer = bufnr,
--                     preserve_mappings = false,
--                 })
--             end)
--             require("lazy-lsp").setup({
--                 excluded_serves = {
--                     "ts_ls"
--                 }
--             })
--         end,
--     } }
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
                ensure_installed = { "omnisharp", "rust_analyzer", "ts_ls", "eslint", "html", "cssls" },
            })

            mason_lspconfig.setup_handlers({
                function(server_name) -- Default handler
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                    })
                end,
            })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Execute code action" })
        end,
    },
}
