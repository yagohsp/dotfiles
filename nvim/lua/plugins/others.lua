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
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require("telescope").setup {
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {
                        }
                    }
                }
            }
            require("telescope").load_extension("ui-select")
        end
    }
}
