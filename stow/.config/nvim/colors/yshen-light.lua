-- yshen-light: light theme built on mini.base16 (base00 = lightest, base07 = darkest)

-- Must come before setup: changing 'background' reloads the active colorscheme
vim.o.background = "light"

require("mini.base16").setup({
	palette = {
		base00 = "#ddcab7", -- background
		base01 = "#d7c3b1", -- alternate background (statusline)
		base02 = "#cebba9", -- selection
		base03 = "#6b5d52", -- comments
		base04 = "#564d46", -- secondary text
		base05 = "#3d352d", -- text
		base06 = "#352a22",
		base07 = "#30261e",
		base08 = "#951b3c", -- variables / errors (sakura)
		base09 = "#803d00", -- numbers / constants (orange)
		base0A = "#5e4c00", -- classes / search (yellow flower)
		base0B = "#395900", -- strings (grass)
		base0C = "#00595d", -- support / regex (teal)
		base0D = "#184b95", -- functions (sky)
		base0E = "#7a2c6b", -- keywords (dark sakura)
		base0F = "#694525", -- wood
	},
	use_cterm = true,
})

vim.g.colors_name = "yshen-light"

-- mini.base16 paints these two the same teal, which flattens languages like asm
vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#184b95" })
vim.api.nvim_set_hl(0, "@label", { fg = "#951b3c", bold = true })

vim.api.nvim_set_hl(0, "@keyword", { fg = "#7a2c6b", italic = true })
vim.api.nvim_set_hl(0, "Cursor", { bg = "#951b3c", fg = "#ddcab7" })
vim.o.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"
