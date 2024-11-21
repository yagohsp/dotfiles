vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.fileformats = { "unix", "dos" }

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.wo.number = true
vim.opt.relativenumber = true
vim.opt.hidden = true
vim.opt.wrap = false


local keymap = vim.api.nvim_set_keymap
local opts = function(desc)
	return { noremap = true, silent = true, desc = desc }
end

--buffer
keymap("n", "<leader>bn", ":bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>bp", ":bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>bd", ":bdelete<CR>", opts("Delete buffer"))
keymap("n", "<leader>bl", ":ls<CR>", opts("List buffer"))
keymap("n", "<leader>bt", ":enew<CR>", opts("New buffer"))

--file
keymap("n", "<Enter>", ":lua vim.lsp.buf.format()<Cr>", opts("Format file"))
keymap("n", "<C-s>", ":w<CR>", opts("Save file"))
keymap("n", "<Enter>", "o<Esc>", opts("Insert spaceline"))
keymap("n", "<leader>q", ":q<CR>", opts("Quit"))
keymap("n", "<leader>e", ":Oil<CR>", opts("File explorer"))
