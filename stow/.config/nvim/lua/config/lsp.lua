local kind = vim.lsp.protocol.CompletionItemKind
-- Godot sends items in its editor's order (own script first) but no sortText; keep that order
-- and push constants/enums to the end
local low_priority = { [kind.Constant] = true, [kind.Enum] = true, [kind.EnumMember] = true }

local order = 0
local function godot_convert(_)
	order = order + 1
	return { _order = order }
end

local function godot_cmp(a, b)
	local ia = vim.tbl_get(a, "user_data", "nvim", "lsp", "completion_item") or {}
	local ib = vim.tbl_get(b, "user_data", "nvim", "lsp", "completion_item") or {}
	local la, lb = low_priority[ia.kind] or false, low_priority[ib.kind] or false
	if la ~= lb then
		return lb
	end
	return (a._order or 0) < (b._order or 0)
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client ~= nil and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, event.buf, {
				autotrigger = true,
				convert = client.name == "Godot" and godot_convert or nil,
				cmp = client.name == "Godot" and godot_cmp or nil,
			})
		end
	end,
})

vim.keymap.set("i", "<Down>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end
	return "<Down>"
end, { expr = true })

vim.keymap.set("i", "<Up>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	end
	return "<Up>"
end, { expr = true })

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>"
	end
	return "<CR>"
end, { expr = true })

local function accept_first()
	if vim.fn.pumvisible() == 1 then
		local selected = vim.fn.complete_info({ "selected" }).selected
		return string.rep("<C-p>", selected + 1) .. "<C-n><C-y>"
	end
	return "<CR>"
end
vim.keymap.set("i", "<S-CR>", accept_first, { expr = true })
vim.keymap.set("i", "<C-CR>", accept_first, { expr = true })

vim.lsp.config("eslint", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"yaml",
		"toml",
		"css",
		"scss",
		"html",
	},
})
