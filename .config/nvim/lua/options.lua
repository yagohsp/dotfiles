local functions = require("functions")

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.fileformats = { "unix", "dos" }
vim.opt.swapfile = false
vim.bo.modifiable = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.wo.number = true
vim.opt.relativenumber = true
vim.opt.hidden = true
vim.opt.wrap = false
vim.opt.scrolloff = 10

vim.opt.cmdheight = 0
vim.opt.showmatch = true

local keymap = vim.api.nvim_set_keymap
local set = vim.keymap.set
local opts = function(desc)
    return { noremap = true, silent = true, desc = desc or "" }
end

vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= "oil" and vim.bo.modified then
            vim.cmd("silent! write")
        end
    end,
})

--nvim
keymap('v', 'Y', '"+y', opts())
keymap("n", "<Esc>", "<cmd>noh<CR>", opts("noh"))
keymap('n', ':', '<cmd>FineCmdline<CR>', opts())
vim.keymap.set("n", "<leader>:", function()
    vim.api.nvim_feedkeys(":", "n", false)
end, opts("Open Neovim cmd"))
keymap('n', '0', '^', opts())
keymap('n', '`', '$', opts())
keymap('n', '<C-a>', "gg<S-v>G", opts())
set('n', '<leader>[', '?{<CR><cmd>noh<CR>', opts("Move to previous opening bracket"))
set('n', '<leader>]', '/}<CR><cmd>noh<CR>', opts("Move to next closing bracket"))
keymap('n', '<Leader>R', '<cmd>lua RunRustFile()<CR>', opts("Run rust file"))
keymap('v', 'r',
    '"hy:.,$s/<C-r>h//gc<left><left><left>',
    opts("Rename selection"))

-- keymap('n', '[', '<Cmd>call search("[([{<]")<CR>', opts())
-- keymap('n', ']', '<Cmd>call search("[([{<]")<CR>', opts())
set('n', '[', function()
    local char = vim.fn.nr2char(vim.fn.getchar())
    vim.fn.search(char, 'b')
end, opts())
set('n', ']', function()
    local char = vim.fn.nr2char(vim.fn.getchar())
    vim.fn.search(char)
end, opts())

set('n', '<C-w>', function()
    vim.fn.search('[A-Z]', 'W')
end, opts("Move to next uppercase character"))

set('n', '<C-b>', function()
    vim.fn.search('[A-Z]', 'bW')
end, opts("Move to previous uppercase character"))

--buffer
keymap("n", "<leader>w", "<cmd>bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>q", "<cmd>bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>D", "<cmd>bdelete!<CR>", opts("Delete buffer"))

--file
keymap("n", "<leader><Enter>", "o<Esc>", opts("Insert spaceline"))
keymap("n", "<leader>Q", "<cmd>w!<CR><cmd>q!<CR>", opts("Quit"))
keymap("n", "<leader>e", "<cmd>Oil<CR>", opts("File explorer"))
keymap("n", "<leader>d", "<cmd>bdelete!<CR><cmd>Oil<CR>", opts("File explorer"))

--lsp
set("n", "<leader>r", vim.lsp.buf.rename, opts("Replace variable"))
set("n", "K", vim.lsp.buf.hover)
set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
set("n", "<leader>lr", vim.lsp.buf.references, { desc = "Go to references" })
set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Execute code action" })
set('n', '<leader>le', vim.diagnostic.open_float, { desc = 'Show errors' })

--gitsigns
set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", opts("Preview changes"))
set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", opts("Toggle git blame"))

--tmux
set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", opts())
set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", opts())
set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", opts())
set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", opts())

--functions
set("n", ";", function()
    local col = vim.fn.col(".")
    vim.cmd("normal! A;")
    vim.fn.cursor(0, col)
end, opts())

function RunRustFile()
    local filename = vim.fn.expand('%<cmd>p')
    vim.cmd('term RUSTFLAGS="-Awarnings" cargo run --bin ' .. vim.fn.fnamemodify("../" .. filename, '<cmd>t<cmd>r'))
end

set('n', '-', function() functions.jump_to_method("next") end,
    { desc = 'Jump to the next method at the same level' })
set('n', '_', function() functions.jump_to_method("previous") end,
    { desc = 'Jump to the previous method at the same level' })
set('v', '-', function() functions.jump_to_method("next") end,
    { desc = 'Jump to the next method at the same level' })
set('v', '_', function() functions.jump_to_method("previous") end,
    { desc = 'Jump to the previous method at the same level' })

--telescope
local builtin = require("telescope.builtin")

set('n', '<leader>p', function() require('telescope.builtin').registers() end, opts("Copy history"))
set("n", "<C-p>", function() builtin.find_files() end, opts("Find files"))
set("n", "<leader><leader>", function() builtin.oldfiles() end, opts("Recent files"))
set("n", "<leader>fm", function() builtin.commands() end, opts("Commands available"))
set("n", "<leader>fh", function() builtin.command_history() end, opts("Commands history"))
set("n", "<leader>ft", function() builtin.live_grep() end, opts("Find text"))
set("n", "<leader>fc", "<cmd>Telescope find_files search_dirs=~/.config/nvim<CR>", opts("Config files"))
set('n', '<leader>ff', function() builtin.lsp_document_symbols({ symbols = { "function" } }); end, opts("Functions"));
set('n', '<leader>fr', function() builtin.lsp_references() end, opts("References"));

--None-ls
set("n", "<leader>F", vim.lsp.buf.format, opts("Format file"))
set("n", "<C-s>", "<cmd>w<CR><cmd>lua vim.lsp.buf.format()<CR>", opts("Save file"))
