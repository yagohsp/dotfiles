return {
    { 'echasnovski/mini.nvim', version = false },
    "jiangmiao/auto-pairs",
    "tpope/vim-commentary",
    "rcarriga/nvim-notify",
    {
        "edluffy/hologram.nvim",
        config = function()
            require("hologram").setup({})
        end
    }
}
