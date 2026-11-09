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
local ok, theme = pcall(vim.fn.readfile, vim.fn.expand("~/.local/state/yshell-light/theme-name"))
vim.cmd("colorscheme " .. (ok and theme[1] or "yshen-light"))

-- vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }
-- vim.cmd("colorscheme catppuccin")
