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
vim.opt.scrolloff = 10

local keymap = vim.api.nvim_set_keymap
local opts = function(desc)
	return { noremap = true, silent = true, desc = desc or "" }
end

--buffer
keymap("n", "<leader>w", ":bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>q", ":bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>bd", ":bdelete<CR>", opts("Delete buffer"))
keymap("n", "<leader>bl", ":ls<CR>", opts("List buffer"))
keymap("n", "<leader>bt", ":enew<CR>", opts("New buffer"))

--file
keymap("n", "<Enter>", ":lua vim.lsp.buf.format()<Cr>", opts("Format file"))
keymap("n", "<C-s>", ":w<CR>", opts("Save file"))
keymap("n", "<Enter>", "o<Esc>", opts("Insert spaceline"))
keymap("n", "<leader>Q", ":q<CR>", opts("Quit"))
keymap("n", "<leader>e", ":Oil<CR>", opts("File explorer"))

keymap("n", "<Esc>", ":noh<CR>", opts("noh"))

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99

vim.keymap.set("n", ";", function()
	local col = vim.fn.col(".")
	vim.cmd("normal! A;")
	vim.fn.cursor(0, col)
end, opts())

vim.keymap.set("v", "<leader>r", function()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local end_line = end_pos[2]

	local lines_to_yank = vim.fn.getline(start_line, end_line)

	local text = table.concat(lines_to_yank, "\n")

	vim.fn.setreg('"', text)

	local substitute_command = ":%s/" .. vim.fn.escape(text, "/\\") .. "/"

	vim.cmd("normal! :")
	vim.fn.feedkeys(substitute_command)
end, opts("Replace selection"))

