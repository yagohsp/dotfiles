-- Move between splits, falling through to the tmux pane at the edge
for key, dir in pairs({ Left = "h", Down = "j", Up = "k", Right = "l" }) do
	vim.keymap.set({ "n", "t" }, "<A-" .. key .. ">", function()
		local win = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(dir)
		if vim.api.nvim_get_current_win() == win and vim.env.TMUX then
			vim.system({ "tmux", "select-pane", "-" .. ({ h = "L", j = "D", k = "U", l = "R" })[dir] })
		end
	end)
end

-- Cycle through splits, then on to the next/previous tmux pane
for key, step in pairs({ l = 1, h = -1 }) do
	vim.keymap.set({ "n", "t" }, "<A-" .. key .. ">", function()
		local edge = step == 1 and vim.fn.winnr("$") or 1
		if vim.fn.winnr() == edge and vim.env.TMUX then
			local panes = vim.system({ "tmux", "display", "-p", "#{window_panes}" }):wait().stdout
			if tonumber(panes) > 1 then
				local target = step == 1 and ":.+" or ":.-"
				local enter = step == 1 and "first" or "last"
				vim.system({ "tmux", "set", "-p", "-t", target, "@nav_enter", enter, ";", "select-pane", "-t", target })
				return
			end
		end
		vim.cmd.wincmd(step == 1 and "w" or "W")
	end)
end

-- Entering this pane with A-l/A-h lands on the first/last split (tmux marks the pane with @nav_enter)
if vim.env.TMUX then
	vim.api.nvim_create_autocmd("FocusGained", {
		callback = function()
			local pane = vim.env.TMUX_PANE
			vim.system({ "tmux", "show", "-pqv", "-t", pane, "@nav_enter" }, {}, function(out)
				local enter = vim.trim(out.stdout or "")
				if enter == "" then
					return
				end
				vim.system({ "tmux", "set", "-pu", "-t", pane, "@nav_enter" })
				vim.schedule(function()
					vim.cmd.wincmd(enter == "first" and "t" or "b")
				end)
			end)
		end,
	})
end
