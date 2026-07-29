return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<F1>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F2>", function() require("dap").step_into() end, desc = "Step into" },
      { "<F3>", function() require("dap").step_out() end, desc = "Step out" },
      { "<F4>", function() require("dap").continue() end, desc = "Continue" },
      {
        "<F5>",
        function()
          local dap = require("dap")
          dap.terminate({
            on_done = function()
              vim.cmd("write")
              dap.continue()
            end,
          })
        end,
        desc = "Restart",
      },
      { "<F6>", function() require("dap").terminate() end, desc = "Terminate" },
      {
        "<F7>",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        desc = "Dap - Eval",
      },
      { "<F8>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<F9>", function() require("dapui").toggle() end, desc = "Toggle UI" },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require "dap"
      dap.set_log_level("DEBUG")
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
        {
          name = "Attach to Next.js",
          type = "node2",
          request = "attach",
          port = 9229,
          protocol = "inspector",
          restart = true,
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
          cwd = vim.fn.getcwd(),
          outFiles = { "${workspaceFolder}/.next/**/*.js" },
        },
      }

      dap.adapters.codelldb = {
        id = 'cppdbg',
        type = 'executable',
        command = mason_path .. '/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { mason_path .. '/node-debug2-adapter/out/src/nodeDebug.js' },
      }

      dap.configurations.rust = {
        {
          name = "Rust debug",
          type = "codelldb",
          request = "launch",
          program = function()
            vim.fn.system("cargo build --debug")
            local cwd = vim.fn.getcwd()
            return cwd .. '/target/debug/' .. vim.fn.fnamemodify(cwd, ':t')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = true,
        },
      }


      dap.adapters.coreclr = {
        type = 'executable',
        command = mason_path .. '/netcoredbg/netcoredbg',
        args = { '--interpreter=vscode' }
      }
      dap.adapters.netcoredbg = {
        type = 'executable',
        command = mason_path .. '/netcoredbg/netcoredbg',
        args = { '--interpreter=vscode' }
      }

      local dotnet = require("easy-dotnet")
      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Attach",
          request = "attach",
          processId = function()
            local dll = dotnet.get_debug_dll(true)
            local app_name = dll.project_name
            local parent_port = vim.fn.system("ps aux | grep " .. app_name .. " | head -n1 | awk -F' ' '{print $2}'")
            local cmd = string.format("pstree -p %d | grep -oP '%s\\(\\K\\d+' | head -n1", parent_port, app_name)
            local port = vim.fn.system(cmd)

            return tonumber(port)
          end,
        },
        {
          type = 'netcoredbg',
          name = 'Launch',
          request = 'launch',
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
            ASPNETCORE_URLS = "http://localhost:8000",
          },
          program = function()
            local dll = dotnet.get_debug_dll(true)
            -- dotnet.build()
            return dll.relative_dll_path
          end,
          cwd = function()
            local dll = dotnet.get_debug_dll(true)
            return dll.relative_project_path
          end
        },
      }

      local dapui = require "dapui"
      dapui.setup({
        layouts = {
          {
            elements = {
              {
                id = "repl",
                size = 0.6
              },
              {
                id = "scopes",
                size = 0.3
              },
              {
                id = "breakpoints",
                size = 0.15
              }
              -- {
              --   id = "watches",
              --   size = 0.3
              -- },
              -- {
              --   id = "console",
              --   size = 0.3
              -- }
            },
            position = "left",
            size = 60
          },
        },
      })
      require("nvim-dap-virtual-text").setup({})

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
    end,
  },
}
