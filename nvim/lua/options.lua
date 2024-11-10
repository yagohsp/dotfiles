vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.wo.number = true            -- Line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.hidden = true           -- Allows buffer switching without saving
vim.opt.wrap = false            -- Disable line wrap

local keymap = vim.api.nvim_set_keymap
local opts = function (desc)
  return { noremap = true, silent = true, desc = desc }
end

keymap('n', '<leader>bn', ':bnext<CR>', opts("Next buffer"))
keymap('n', '<leader>bp', ':bprevious<CR>', opts("Previous buffer"))
keymap('n', '<leader>bd', ':bdelete<CR>', opts("Delete buffer"))
keymap('n', '<leader>bl', ':ls<CR>', opts("List buffer"))
keymap('n', '<leader>bt', ':enew<CR>', opts("New buffer"))
keymap('n', '<Enter>', 'o<Esc>', opts("Insert spaceline"))
keymap('n', '<C-s>', ':w<CR>', opts("Save file"))
keymap('n', '<leader>q', ':q<CR>', opts("Quit"))
keymap('n', '<leader>e', ':Ex<CR>', opts("File explorer"))
keymap('n', '<leader>cf', '<cmd>cd %:h <CR>', opts(""))
