return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dap.adapters.coreclr = {
				type = "executable",
				command = "/home/yago/Applications/netcoredbg/netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "launch - netcoredbg",
					request = "launch",
					program = function()
						local dll_files = vim.fn.glob(vim.fn.getcwd() .. "/bin/Debug/**/*.dll", false, true)
            print(string.format("%s", dll_files[0]))
						return vim.fn.input("Path to dll", dll_files[1], "file")
					end,
				},
			}

			vim.keymap.set("n", "<F5>", function()
				dap.toggle_breakpoint()
			end, { desc = "Toggle breakpoint" })
			vim.keymap.set("n", "<F4>", function()
				dap.continue()
			end, { desc = "Continue debugging" })

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}
