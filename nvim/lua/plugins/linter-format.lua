return {
    {
        "mfussenegger/nvim-lint",
        event = {
            "BufReadPre",
            "BufNewFile",
        },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                css = { "eslint_d" },
                html = { "eslint_d" },
                json = { "eslint_d" },
                jsx = { "eslint_d" },
                javascript = { "eslint_d" },
                markdown = { "eslint_d" },
                scss = { "eslint_d" },
                typescript = { "eslint_d" },
                yalm = { "eslint_d" },
            }

            local lint_group = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_group,
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                formatters_by_ft = {
                    javascript = { "prettier_d" },
                    typescript = { "prettier_d" },
                    javascriptreact = { "prettier_d" },
                    typescriptreact = { "prettier_d" },
                    html = { "prettier_d" },
                    css = { "prettier_d" },
                    json = { "prettier_d" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                },
            })
        end
    }
}
