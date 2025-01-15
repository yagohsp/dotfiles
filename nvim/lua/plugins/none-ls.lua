return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.prettierd,
                null_ls.builtins.formatting.clang_format.with({
                    extra_args = { "--style", "file" },
                }),
                null_ls.builtins.diagnostics.eslint,
            },
        })
    end,
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
}
