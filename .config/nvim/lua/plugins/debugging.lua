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
      dapui.setup({
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.35
              },
              {
                id = "console",
                size = 0.45
              },
              {
                id = "breakpoints",
                size = 0.2
              },
            },
            position = "left",
            size = 60
          },
        },
      })

      local mason_path = os.getenv('HOME') .. '/.local/share/nvim/mason/packages'
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { mason_path .. '/node-debug2-adapter/out/src/nodeDebug.js' },
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
          request = 'launch',
          name = 'Debug Jest Tests',
          program = '${workspaceFolder}/node_modules/jest/bin/jest.js',
          args = { '--runTestsByPath', '${file}', '--coverage=false' },
          port = 9229,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          skipFiles = { '<node_internals>/**' },
          console = 'integratedTerminal',
          runtimeArgs = { '--inspect-brk' },
        },
        {
          type = 'node2',
          request = 'attach',
          name = 'Attach to ts App',
          port = 9229,
          restart = false,
          sourceMaps = true,
          protocol = 'inspector',
          cwd = vim.fn.getcwd(),
          skipFiles = { '<node_internals>/**' },
          outFiles = { "${workspaceFolder}/.next/**/*.js" },
        },
      }

      dap.adapters.codelldb = {
        id = 'cppdbg',
        type = 'executable',
        command = mason_path .. '/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }

      dap.configurations.rust = {
        {
          name = "Rust debug",
          type = "codelldb",
          request = "launch",
          program = function()
            vim.fn.system("cargo build")
            local cwd = vim.fn.getcwd()
            return cwd .. '/target/debug/' .. vim.fn.fnamemodify(cwd, ':t')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = true,
        },
      }

      vim.keymap.set("n", "<leader>b?", function()
        require("dapui").eval(nil, { enter = true })
      end, { desc = "Dap - Eval" })

      vim.keymap.set("n", "<F1>", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<F2>", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Step out" })

      vim.keymap.set("n", "<F4>", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<F5>", function()
        os.execute("cargo build");
        dap.terminate({
          on_done = function()
            vim.cmd('write')
            dap.continue()
          end
        });
      end, { desc = "Restart" })
      vim.keymap.set("n", "<F6>", dap.terminate, { desc = "Terminate" })
      vim.keymap.set("n", "<F8>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<F9>", dapui.toggle, { desc = "Toggle UI" })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited.dapui_config = function()
      --   dapui.close()
      -- end
    end,
  },
}
