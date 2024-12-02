return {
    "nvimtools/none-ls.nvim",

    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        -- local null_ls = require("null-ls")

        -- null_ls.setup({
        -- 	sources = {
        -- 		null_ls.builtins.formatting.stylua,
        -- 		null_ls.builtins.formatting.prettier,
        -- 		null_ls.builtins.formatting.csharpier,
        -- 		require("none-ls.diagnostics.eslint"),
        -- 	},
        -- })

        vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { noremap = true, silent = true, desc = "Format file" })
        vim.keymap.set("n", "<C-s>", ":w<CR>:lua vim.lsp.buf.format()<CR>",
            { noremap = true, silent = true, desc = "Save file" })
    end,
}
