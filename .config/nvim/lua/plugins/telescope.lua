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
        end,
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
}
