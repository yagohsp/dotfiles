return {
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "catppuccin",
                },
                sections = {
                    -- lualine_a = { "mode" },
                    lualine_a = {},
                    -- lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_b = {},
                    lualine_c = { "buffers" },
                    lualine_x = { "filetype" },
                    lualine_y = {},
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    -- lualine_c = { "filename" },
                    lualine_c = {},
                    -- lualine_x = { "location" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },
    {
        "VonHeikemen/fine-cmdline.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("fine-cmdline").setup({
                popup = {
                    position = {
                        row = "80%",
                    },
                    size = {
                        width = "40%",
                    },
                },
            })
        end,
    },
    {
        "xiyaowong/transparent.nvim",
    },
    {
        "max397574/colortils.nvim",
        cmd = "Colortils",
        config = function()
            require("colortils").setup()
        end,
    }
}
