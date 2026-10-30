vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
})
require("lualine").setup({
	sections = {
		lualine_a = { "branch" },
		lualine_b = {},
		lualine_c = {
			{
				"buffers",
				mode = 0,
				symbols = {
					modified = " •",
					alternate_file = "",
				},
				buffers_color = {
					active = { fg = "#1e1e2e", bg = "#cba6f7", gui = "bold" },
					inactive = { fg = "#6c7086", bg = "NONE" },
				},
			},
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})
