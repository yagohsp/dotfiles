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
keymap("n", "<leader>D", ":bdelete<CR>", opts("Delete buffer"))
-- keymap("n", "<leader>bl", ":ls<CR>", opts("List buffer"))
-- keymap("n", "<leader>bt", ":enew<CR>", opts("New buffer"))

--file
-- keymap("n", "<C-s>", ":w<CR>", opts("Save file"))
keymap("n", "<Enter>", "o<Esc>", opts("Insert spaceline"))
keymap("n", "<leader>Q", ":w<CR>:q<CR>", opts("Quit"))
keymap("n", "<leader>e", ":Oil<CR>", opts("File explorer"))

keymap('v', 'Y', '"+y', opts())
keymap("n", "<Esc>", ":noh<CR>", opts("noh"))

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts("Replace selection"))
vim.keymap.set("v", "<leader>r", [[:<C-u>%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>]], opts("Replace selection"))

vim.keymap.set("n", ";", function()
    local col = vim.fn.col(".")
    vim.cmd("normal! A;")
    vim.fn.cursor(0, col)
end, opts())
