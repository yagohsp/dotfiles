return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                file_ignore_patterns = { "node_modules/.*" },
                dependencies = {
                    'nvim-lua/plenary.nvim',
                    'BurntSushi/ripgrep'
                }
            })
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, { desc = "Recent files" })
            vim.keymap.set("n", "<leader>fm", builtin.commands, { desc = "Commands available" })
            vim.keymap.set("n", "<leader>fh", builtin.command_history, { desc = "Commands history" })
            vim.keymap.set("n", "<leader>ft", builtin.live_grep, { desc = "Find text" })

            vim.keymap.set("n", "<leader>fc", ":Telescope find_files search_dirs=~/.config/nvim<CR>",
                { desc = "Config files" })

            vim.keymap.set('n', '<leader>ff', function()
                require('telescope.builtin').lsp_document_symbols({ symbols = { "function" } });
            end, { desc = "Functions" });

            vim.keymap.set('n', '<leader>fr', function()
                require('telescope.builtin').lsp_references();
            end, { desc = "References" })
        end,
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
}