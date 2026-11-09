vim.pack.add({
	{
		src = "https://github.com/rose-pine/neovim",
		name = "rose-pine",
	},
	"https://github.com/nvim-mini/mini.base16",
})

require("rose-pine").setup({
	variant = "main"
})
-- vim.cmd("colorscheme rose-pine")
vim.cmd("colorscheme sakura-tren")

-- vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }
-- vim.cmd("colorscheme catppuccin")
