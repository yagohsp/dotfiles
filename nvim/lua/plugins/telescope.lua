return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local actions = require("telescope.actions")
            require("telescope").setup({
                pickers = {
                    find_files = {
                        hidden = true
                    }
                },
                defaults = {
                    mappings = {
                        i = {
                            ["<S-Tab>"] = actions.move_selection_next,
                            ["<Tab>"] = actions.move_selection_previous,
                        },
                    },
                    file_ignore_patterns = { ".git/" },
                },
                dependencies = {
                    "BurntSushi/ripgrep",
                },
            })
        end,
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
}
