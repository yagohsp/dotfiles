vim.pack.add({
	{
		src = "https://github.com/rose-pine/neovim",
		name = "rose-pine",
	},
})

require("rose-pine").setup({
	variant = "main"
})
vim.cmd("colorscheme rose-pine")

-- vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }
-- vim.cmd("colorscheme catppuccin")
