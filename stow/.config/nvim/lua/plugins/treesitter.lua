vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" } })

require("nvim-treesitter").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

-- nvim-treesitter no longer starts highlighting itself; start it wherever a parser exists
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
