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
local set = vim.keymap.set
local opts = function(desc)
    return { noremap = true, silent = true, desc = desc or "" }
end

--buffer
keymap("n", "<leader>w", ":bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>q", ":bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>D", ":bdelete!<CR>", opts("Delete buffer"))

--file
keymap("n", "<Enter>", "o<Esc>", opts("Insert spaceline"))
keymap("n", "<leader>Q", ":w<CR>:q<CR>", opts("Quit"))
keymap("n", "<leader>e", ":Oil<CR>", opts("File explorer"))

--nvim
keymap('v', 'Y', '"+y', opts())
keymap("n", "<Esc>", ":noh<CR>", opts("noh"))

--fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99

--lsp
set("n", "<leader>r", vim.lsp.buf.rename, opts("Replace selection"))
set(
    "n",
    "<leader>ld",
    vim.lsp.buf.definition, opts("Go to definition"),
    opts("Execute code actions")
)
set(
    "n",
    "<leader>la",
    vim.lsp.buf.code_action,
    opts("Execute code actions")
)
set('n', 'lt', vim.lsp.buf.type_definition, opts("Go to type definition"))
set('n', 'li', vim.lsp.buf.implementation, opts("Go to type implementation"))
set('n', 'K', vim.lsp.buf.hover)
set('n', 'le', vim.diagnostic.open_float, opts("Show errors"))

--gitsigns
vim.opt.signcolumn = "yes"
set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", opts("Preview changes"))
set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", opts("Toggle git blame"))

--tmux
set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", opts(""))
set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", opts(""))
set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", opts(""))
set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", opts(""))

--functions
set("n", ";", function()
    local col = vim.fn.col(".")
    vim.cmd("normal! A;")
    vim.fn.cursor(0, col)
end, opts())

--telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fm", builtin.commands, { desc = "Commands available" })
vim.keymap.set("n", "<leader>fh", builtin.command_history, { desc = "Commands history" })
vim.keymap.set("n", "<leader>ft", builtin.live_grep, { desc = "Find text" })

vim.keymap.set("n", "<leader>fc", ":Telescope find_files search_dirs=~/.config/nvim<CR>",
    { desc = "Config files" })

vim.keymap.set('n', '<leader>ff', function()
    builtin.lsp_document_symbols({ symbols = { "function" } });
end, { desc = "Functions" });

vim.keymap.set('n', '<leader>fr', function()
    builtin.lsp_references();
end, { desc = "References" })
