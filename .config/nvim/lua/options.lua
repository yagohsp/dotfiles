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
    "<leader>la",
    vim.lsp.buf.code_action,
    opts("Execute code actions")
)

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

set("n", "<C-p>", function()
    builtin.find_files()
end, opts("Find files"))

set("n", "<leader><leader>", function()
    builtin.oldfiles()
end, opts("Recent files"))

set("n", "<leader>fm", function()
    builtin.commands()
end, opts("Commands available"))

set("n", "<leader>fh", function()
    builtin.command_history()
end, opts("Commands history"))

set("n", "<leader>ft", function()
    builtin.live_grep()
end, opts("Find text"))

set("n", "<leader>fc", ":Telescope find_files search_dirs=~/.config/nvim<CR>",
    opts("Config files"))

set('n', '<leader>ff', function()
    builtin.lsp_document_symbols({ symbols = { "function" } });
end, opts("Functions"));

set('n', '<leader>fr', function()
    builtin.lsp_references()
end, opts("References"));
