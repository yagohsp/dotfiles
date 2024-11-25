require("lazy").setup({
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    "nvim-lualine/lualine.nvim",
    "nvim-treesitter/nvim-treesitter",
    "christoomey/vim-tmux-navigator",
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
})
