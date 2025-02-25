return {
    "rcarriga/nvim-notify",
    {
        "edluffy/hologram.nvim",
        config = function()
            require("hologram").setup({})
        end
    },
    "tpope/vim-surround",
    "abecodes/tabout.nvim",
    {
        "ten3roberts/qf.nvim",
        config = function()
            require("qf").setup()
        end
    }
}
