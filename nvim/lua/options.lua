vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.fileformats = { "unix", "dos" }
vim.opt.swapfile = false
vim.opt.modifiable = true

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.hidden = true
vim.opt.textwidth = 80
vim.opt.scrolloff = 10
vim.opt.signcolumn = "no"

vim.opt.cmdheight = 1
vim.opt.showmatch = true

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.api.nvim_set_hl(0, "Folded", { bg = "#151521" })

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
keymap("n", "<A-y>", '"+y', opts())
keymap("v", "<A-y>", '"+y', opts())
keymap("n", "<Esc>", "<cmd>noh<CR>", opts("noh"))
keymap("n", ":", "<cmd>FineCmdline<CR>", opts())
vim.keymap.set("n", "<leader>:", function()
    vim.api.nvim_feedkeys(":", "n", false)
end, opts("Open Neovim cmd"))
keymap("n", "0", "^", opts())
keymap("n", "`", "$", opts())
keymap("n", "<C-a>", "gg<S-v>G", opts())
keymap("v", "r", '"hy:.,$s/<C-r>h//gc<left><left><left>', opts("Rename selection"))
keymap("n", "<A-j>", '8j', opts())
keymap("n", "<A-k>", '8k', opts())
keymap("v", "<A-j>", '8j', opts())
keymap("v", "<A-k>", '8k', opts())
keymap("n", "zH", '10zH', opts())

--buffer
keymap("n", "<leader>w", "<cmd>bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>q", "<cmd>bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>d", "<cmd>bdelete!<CR><cmd>Oil<CR>", opts("Delete buffer"))
keymap("n", "<leader>D", "<cmd>bdelete!<CR>", opts("Delete buffer"))

--file
keymap("n", "<leader>Q", "<cmd>silent! w!<CR><cmd>q!<CR>", opts("Quit"))
keymap("n", "<leader>e", "<cmd>Oil<CR>", opts("File explorer"))

vim.api.nvim_set_keymap('n', '<A-d>', '"_d', opts())
vim.api.nvim_set_keymap('v', '<A-d>', '"_d', opts())
vim.api.nvim_set_keymap('n', '<A-D>', '"_D', opts())
vim.api.nvim_set_keymap('v', '<A-D>', '"_D', opts())
vim.api.nvim_set_keymap('n', '<A-c>', '"_c', opts())
vim.api.nvim_set_keymap('v', '<A-c>', '"_c', opts())
vim.api.nvim_set_keymap('n', '<A-C>', '"_C', opts())
vim.api.nvim_set_keymap('v', '<A-C>', '"_C', opts())

--lsp
set("n", "<leader>r", vim.lsp.buf.rename, opts("Replace variable"))
set("n", "K", vim.lsp.buf.hover)
set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
set("n", "<leader>lr", vim.lsp.buf.references, { desc = "Go to references" })
set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Execute code action" })
set("n", "<leader>le", vim.diagnostic.open_float, { desc = "Show errors" })

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

function fold(n)
    vim.opt.foldlevel = n
end

--fold
keymap("n", "z1", "<cmd>lua fold(0)<CR>", opts("Fold at 1"))
keymap("n", "z2", "<cmd>lua fold(1)<CR>", opts("Fold at 2"))
keymap("n", "z3", "<cmd>lua fold(2)<CR>", opts("Fold at 3"))
keymap("n", "z0", "<cmd>lua fold(99)<CR>", opts("Unfold all"))
set("n", "zo", function()
    if vim.fn.foldclosed(".") == -1 then
        vim.cmd("normal! zC")
    else
        vim.cmd("normal! zO")
    end
end, opts("Unfold current"))

function JumpOverFold(direction)
    if direction == 'up' then
        if vim.fn.foldclosed('.') ~= -1 then
            vim.cmd('normal! [z')
        end
        vim.cmd('normal! {')
    else
        if vim.fn.foldclosed('.') ~= -1 then
            vim.cmd('normal! ]z')
        end
        vim.cmd('normal! }')
    end
end

-- Remap { and } to use the custom function
vim.api.nvim_set_keymap('n', '{', ':lua JumpOverFold("up")<CR>', opts())
vim.api.nvim_set_keymap('n', '}', ':lua JumpOverFold("down")<CR>', opts())

--telescope
local builtin = require("telescope.builtin")

set("n", "<leader>p", function()
    require("telescope.builtin").registers()
end, opts("Copy history"))

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

set("n", "<leader>fc", "<cmd>Telescope find_files search_dirs=~/.config/nvim<CR>", opts("Config files"))

set("n", "<leader>ff", function()
    builtin.lsp_document_symbols({ symbols = { "function" } })
end, opts("Functions"))

set("n", "<leader>fr", function()
    builtin.lsp_references()
end, opts("References"))

--format
set("n", "<leader>F", "<cmd>:silent! lua lint.try_lint()<CR>", opts("Format file"))
set("n", "<C-s>", "<cmd>:silent! lua lint.try_lint()<CR><cmd>w<CR>", opts("Save file"))
