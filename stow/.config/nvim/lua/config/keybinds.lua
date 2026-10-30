vim.g.mapleader = " "

local function format(silent)
	local eslint = vim.lsp.get_clients({ bufnr = 0, name = "eslint" })
	if #eslint > 0 then
		vim.cmd("LspEslintFixAll")
	elseif not silent or #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" }) > 0 then
		vim.lsp.buf.format({ async = false })
	end
end

vim.keymap.set("n", "<C-s>", function()
	format(true)
	vim.cmd("update")
end)

vim.keymap.set("n", "<leader>f", function()
	format(false)
end)

vim.keymap.set("n", "<leader>R", "<cmd>restart<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>qa!<CR>")
vim.keymap.set({ "n", "v" }, "<C-y>", '"+y')
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>")

vim.keymap.set("n", "<C-d>", "<cmd>bdelete!<CR>")
vim.keymap.set("n", "<C-j>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>bprev<CR>")

vim.keymap.set("n", "<DOWN>", "ddp")
vim.keymap.set("n", "<UP>", "ddk<S-p>")

vim.keymap.set({ "n", "v" }, "<A-j>", "7j")
vim.keymap.set({ "n", "v" }, "<A-k>", "7k")
vim.keymap.set({ "n", "v" }, "<S-A-j>", "14j")
vim.keymap.set({ "n", "v" }, "<S-A-k>", "14k")
vim.keymap.set("n", "<A-a>", "ggVG")

vim.keymap.set("n", "<A-r>", "<cmd>restart<CR>")

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>u", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<C-l>", vim.diagnostic.open_float)

-- Substitute the selection, starting at the selection itself instead of the start of the line
vim.keymap.set("x", "r", function()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	local text = table.concat(vim.tbl_map(function(l)
		return vim.fn.escape(l, [[\/]])
	end, lines), [[\n]])
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	vim.ui.input({ prompt = "Replace with: ", default = #lines == 1 and lines[1] or "" }, function(replacement)
		if replacement then
			vim.cmd([['<,$s/\V\%(\%'<\|\%>'<\)]] .. text .. "/" .. vim.fn.escape(replacement, [[\/&~]]) .. "/gc")
		end
	end)
end)

vim.keymap.set("n", "(", function()
	vim.diagnostic.jump({ count = 1 })
end)

vim.keymap.set("n", ")", function()
	vim.diagnostic.jump({ count = -1 })
end)

vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end)

-- Swap ' with $ and - with ^
vim.keymap.set({ "n", "x", "o" }, "'", "$")
vim.keymap.set({ "n", "x", "o" }, "$", "'")
vim.keymap.set({ "n", "x", "o" }, "-", "^")
vim.keymap.set({ "n", "x", "o" }, "^", "-")

vim.keymap.set("n", "<C-c>", function()
	local qf = vim.fn.getqflist({ winid = 0 })
	if qf.winid ~= 0 then
		vim.cmd.cclose()
	else
		vim.cmd.copen()
	end
end)
vim.keymap.set("n", "<C-Down>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-Up>", "<cmd>cprev<CR>zz")
