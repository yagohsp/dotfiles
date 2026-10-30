local port = tonumber(os.getenv('GDScript_Port') or '6005')
local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
local pipe = '/tmp/godot.pipe'

-- Called by Godot's external editor command to raise this Neovim's terminal
function GodotFocus()
	local pid = vim.fn.getpid()
	local pane = os.getenv('TMUX_PANE')
	if pane then
		vim.system({ 'tmux', 'select-window', '-t', pane }):wait()
		vim.system({ 'tmux', 'select-pane', '-t', pane }):wait()
		pid = tonumber(vim.system({ 'tmux', 'display', '-p', '-t', pane, '#{client_pid}' }):wait().stdout)
	end

	while pid and pid > 1 do
		local win = vim.system({ 'xdotool', 'search', '--pid', tostring(pid) }):wait().stdout:match('%d+')
		if win then
			vim.system({ 'i3-msg', '[id=' .. win .. '] focus' })
			return
		end
		pid = tonumber(vim.system({ 'ps', '-o', 'ppid=', '-p', tostring(pid) }):wait().stdout)
	end
end

-- Like Godot's editor: open completion after a short pause while typing a name
local timer = vim.uv.new_timer()
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd("TextChangedI", {
	group = vim.api.nvim_create_augroup("GodotCompletion" .. buf, { clear = true }),
	buffer = buf,
	callback = function()
		timer:stop()
		local col = vim.fn.col(".") - 1
		if vim.fn.pumvisible() == 1 or not vim.api.nvim_get_current_line():sub(col, col):match("[%w_@]") then
			return
		end
		timer:start(300, 0, vim.schedule_wrap(function()
			if vim.api.nvim_get_mode().mode == "i" and vim.fn.pumvisible() == 0 then
				vim.lsp.completion.get()
			end
		end))
	end,
})

vim.lsp.start({
	name = 'Godot',
	cmd = cmd,
	root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
	on_attach = function(client, bufnr)
		if not vim.tbl_contains(vim.fn.serverlist(), pipe) then
			pcall(vim.fn.serverstart, pipe)
		end
	end
})
