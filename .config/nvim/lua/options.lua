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

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.hidden = true
vim.opt.textwidth = 80
vim.opt.scrolloff = 10
vim.opt.signcolumn = "auto"

vim.opt.cmdheight = 1
vim.opt.showmatch = true

local keymap = vim.api.nvim_set_keymap
local set = vim.keymap.set

local opts = function(desc)
  return { noremap = true, silent = true, desc = desc or "" }
end

vim.diagnostic.config({
  signs = false
})

--nvim
keymap("n", "<A-y>", '"+y', opts())
keymap("v", "<A-y>", '"+y', opts())
keymap("n", "<Esc>", "<cmd>noh<CR>", opts("noh"))
keymap("n", "<A-a>", "gg<S-v>G", opts())
keymap("v", "r", '"hy:.,$s/<C-r>h//gc<left><left><left>', opts("Rename selection"))
vim.keymap.set("n", "<leader>:", function()
  vim.api.nvim_feedkeys(":", "n", false)
end, opts("Open Neovim cmd"))

keymap("n", "<A-j>", '7j', opts())
keymap("n", "<A-k>", '7k', opts())
keymap("v", "<A-j>", '7j', opts())
keymap("v", "<A-k>", '7k', opts())
keymap("n", "<S-A-j>", '16j', opts())
keymap("n", "<S-A-k>", '16k', opts())
keymap("v", "<S-A-j>", '16j', opts())
keymap("v", "<S-A-k>", '16k', opts())

--buffer
keymap("n", "<leader>j", "<cmd>bnext<CR>", opts("Next buffer"))
keymap("n", "<leader>k", "<cmd>bprevious<CR>", opts("Previous buffer"))
keymap("n", "<leader>d", "<cmd>bdelete!<CR>", opts("Delete buffer"))

--file
keymap("n", "<leader>q", "<cmd>silent! w!<CR><cmd>q!<CR>", opts("Quit"))
vim.keymap.set("n", "<leader>e", function()
  local MiniFiles = require("mini.files")
  local buf_name = vim.api.nvim_buf_get_name(0)
  local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
  MiniFiles.open(path)
  MiniFiles.reveal_cwd()
end, { desc = "Open Mini Files" })

keymap('n', '<A-d>', '"_d', opts())
keymap('v', '<A-d>', '"_d', opts())
keymap('n', '<A-D>', '"_D', opts())
keymap('v', '<A-D>', '"_D', opts())
keymap('n', '<A-c>', '"_c', opts())
keymap('v', '<A-c>', '"_c', opts())
keymap('n', '<A-C>', '"_C', opts())
keymap('v', '<A-C>', '"_C', opts())

keymap('v', '<leader>l', 'yoconsole.debug("<esc>pa: ", <esc>pa)<esc>', opts())

--lsp
set("n", "K", vim.lsp.buf.hover)
set("n", "L", vim.diagnostic.open_float, { desc = "Show errors" })
set("n", "<leader>r", vim.lsp.buf.rename, opts("Replace variable"))
set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
set("n", "<leader>lr", vim.lsp.buf.references, { desc = "Go to references" })
set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Execute code action" })

--functions
set("n", ";", function()
  local col = vim.fn.col(".")
  vim.cmd("normal! A;")
  vim.fn.cursor(0, col)
end, opts())

--quickfix
keymap("n", "<leader>co", "<cmd>copen<CR>", opts("Open quickfix"))
keymap("n", "<leader>cc", "<cmd>cclose<CR>", opts("Close quickfix"))
keymap("n", "<leader>cj", "<cmd>cnext<CR>", opts("Next quickfix"))
keymap("n", "<leader>ck", "<cmd>cprevious<CR>", opts("Previous quickfix"))
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'qf' },
  callback = function()
    vim.defer_fn(function()
      vim.cmd("wincmd p")
    end, 10)
  end,
})


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
set("n", "<C-s>", "<cmd>:silent! lua lint.try_lint()<CR><cmd>w<CR>", opts("Save file and format"))
set("n", "<A-s>", "<cmd>:silent! noa w<CR>", opts("Save file"))

local get_listed_bufs = function()
  return vim.tbl_filter(function(bufnr)
    return vim.api.nvim_buf_get_option(bufnr, "buflisted")
  end, vim.api.nvim_list_bufs())
end

local function close_empty_unnamed_buffers()
  local buffers = get_listed_bufs()

  if (#buffers == 2) then
    local buffer_name = vim.api.nvim_buf_get_name(buffers[2])
    if (buffer_name == "") then
      vim.cmd('Dashboard')
    end
  end
end

vim.api.nvim_create_autocmd("BufDelete", {
  callback = close_empty_unnamed_buffers
})
