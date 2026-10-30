vim.o.number = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.undofile = true
vim.o.swapfile = false
vim.o.autoread = true
vim.o.cmdheight = 0
vim.o.signcolumn = "no"
vim.o.wrap = false

vim.cmd("set completeopt+=menuone,noselect")
vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
})
