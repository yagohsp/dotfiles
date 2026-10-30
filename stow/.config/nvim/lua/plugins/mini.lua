vim.pack.add({
	"https://github.com/nvim-mini/mini.cmdline",
	"https://github.com/nvim-mini/mini.files",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-mini/mini.jump",
	"https://github.com/nvim-mini/mini.move",
	"https://github.com/nvim-mini/mini.pairs",
	"https://github.com/nvim-mini/mini.surround",
	"https://github.com/nvim-mini/mini.pick",
	"https://github.com/nvim-mini/mini.extra",
})

require("mini.cmdline").setup()
-- Arrows move through command-line suggestions when shown, otherwise browse history
vim.keymap.set("c", "<Down>", function()
	return vim.fn.wildmenumode() == 1 and "<C-n>" or "<Down>"
end, { expr = true })
vim.keymap.set("c", "<Up>", function()
	return vim.fn.wildmenumode() == 1 and "<C-p>" or "<Up>"
end, { expr = true })
require("mini.icons").setup()
require("mini.jump").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

require("mini.files").setup({
	mappings = {
		close = "<ESC>",
		go_in_plus = "<CR>",
		synchronize = "<C-s>",
	},
	options = {
		permanent_delete = false,
	},
})
vim.keymap.set("n", "<C-e>", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end)

require("mini.move").setup({
	mappings = {
		left = "<LEFT>",
		right = "<RIGHT>",
		down = "<DOWN>",
		up = "<UP>",
		line_left = "<LEFT>",
		line_right = "<RIGHT>",
		line_down = "<DOWN>",
		line_up = "<UP>",
	},
})

local mini_pick = require("mini.pick")
mini_pick.setup()

vim.keymap.set("n", "<C-p>", function()
	mini_pick.builtin.cli({
		command = { "rg", "--files", "--color=never", "--glob=!*.uid" },
	}, {
		source = {
			name = "Files",
			show = function(buf_id, items, query)
				mini_pick.default_show(buf_id, items, query, { show_icons = true })
			end,
		},
	})
end)

vim.keymap.set("n", "<C-f>", function()
	mini_pick.builtin.grep_live()
end)

vim.keymap.set("n", "<leader>p", function()
	mini_pick.builtin.files({}, {
		source = {
			cwd = vim.fn.stdpath("config"),
			name = "Neovim config",
		},
	})
end)

local mini_extra = require("mini.extra")
mini_extra.setup()

local function normalize_path(path)
	if path == nil or path == "" then
		return nil
	end
	return vim.fn.fnamemodify(path, ":p")
end

local function remember_file(path)
	path = normalize_path(path)
	if path == nil or vim.fn.filereadable(path) == 0 then
		return
	end

	local oldfiles = vim.deepcopy(vim.v.oldfiles or {})
	for i, file in ipairs(oldfiles) do
		if normalize_path(file) == path then
			table.remove(oldfiles, i)
			break
		end
	end
	table.insert(oldfiles, 1, path)
	vim.v.oldfiles = oldfiles
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		remember_file(vim.api.nvim_buf_get_name(args.buf))
	end,
})

vim.keymap.set("n", "<C-h>", function()
	local items = {}
	local seen = {}
	local current = normalize_path(vim.api.nvim_buf_get_name(0))

	local function add(path)
		path = normalize_path(path)
		if path == nil or seen[path] or path == current or vim.fn.filereadable(path) == 0 then
			return
		end
		seen[path] = true
		table.insert(items, { text = vim.fn.fnamemodify(path, ":~:."), path = path })
	end

	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	table.sort(bufs, function(a, b)
		return (a.lastused or 0) > (b.lastused or 0)
	end)
	for _, buf in ipairs(bufs) do
		add(buf.name)
	end

	for _, file in ipairs(vim.v.oldfiles or {}) do
		add(file)
	end

	mini_pick.start({
		source = {
			name = "Recent files",
			items = items,
			choose = mini_pick.default_choose,
		},
	})
end)
