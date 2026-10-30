local M = {}

local data_dir = vim.fn.stdpath("data") .. "/termyago"
local data_file = data_dir .. "/state"

local job_id
local win
local buf

local function load_command()
	local file = io.open(data_file, "r")

	if not file then
		return
	end

	local value = file:read("*a")
	file:close()

	return value
end

local function stop_process()
	if job_id then
		vim.fn.jobstop(job_id)
		job_id = nil
	end
end

local function close_window()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end

	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	win = nil
	buf = nil
end

local function close_terminal()
	stop_process()
	close_window()
end

local function save_command(command)
	vim.fn.mkdir(data_dir, "p")

	local file = assert(io.open(data_file, "w"))
	file:write(command)
	file:close()
end

function M.open()
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	buf = vim.api.nvim_create_buf(false, true)

	vim.keymap.set("t", "<Esc>", close_terminal, {
		buffer = buf,
		silent = true,
	})

	win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "single",
	})

	vim.wo[win].number = false

	local command = load_command() or ""

	job_id = vim.fn.jobstart({ "bash", "-c", command .. "\nexec bash" }, {
		term = true,
	})
	vim.cmd("startinsert")
end

function M.setup()
	vim.keymap.set("n", "<C-u>", function()
		M.open()
	end)

	vim.api.nvim_create_user_command("SetCmd", function(opts)
		save_command(opts.args)
	end, { nargs = "*" })
end

return M
