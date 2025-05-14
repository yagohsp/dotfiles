return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()

      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { os.getenv('HOME') .. '/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
      }

      dap.configurations.javascript = {
        {
          type = 'node2',
          request = 'launch',
          name = 'Launch Node.js file',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
      }

      dap.configurations.typescript = {
        {
          type = 'node2',
          request = 'attach',
          name = 'Attach to ts App',
          -- processId = require 'dap.utils'.pick_process,
          port = 9230,
          restart = false,
          sourceMaps = true,
          protocol = 'inspector',
          cwd = vim.fn.getcwd(),
          skipFiles = { '<node_internals>/**' },
          outFiles = { "${workspaceFolder}/.next/**/*.js" }, -- Map transpiled files from `.next` directory
        },
      }

      vim.keymap.set("n", "<leader>bb", dapui.toggle, { desc = "Toggle UI" })

      vim.keymap.set("n", "<leader>bt", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>bc", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>b?", function()
        require("dapui").eval(nil, { enter = true })
      end, { desc = "Dap - Eval" })

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
