return {
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        html = { "htmlhint" },
        jsx = { "eslint_d" },
        javascript = { "eslint" },
        typescript = { "eslint_d" },
      }

      local lint_group = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function()
          vim.cmd("silent! lua require('lint').try_lint()")
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        log_level = vim.log.levels.DEBUG,
        formatters_by_ft = {
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          javascriptreact = { "prettierd" },
          typescriptreact = { "prettierd" },
          html = { "prettierd" },
          css = { "prettierd" },
          json = { "prettierd" },
          lua = { "stylua " },
          cs = { "csharpier" },
          sh = { "beautysh" }
        },
        format = {
          async = true,
          lsp_format = "fallback",
        },
        format_on_save = {
          lsp_format = "fallback",
        },
        formatters = {
          csharpier = function()
            local useDotnet = not vim.fn.executable("csharpier")
            local command = useDotnet and "dotnet csharpier" or "csharpier"
            local version_out = vim.fn.system(command .. " --version")
            --NOTE: system command returns the command as the first line of the result, need to get the version number on the final line
            local version_result = version_out[#version_out]
            local major_version = tonumber((version_out or ""):match("^(%d+)")) or 0
            local is_new = major_version >= 1
            local args = is_new and { "format", "$FILENAME" } or { "--write-stdout" }
            return {
              command = command,
              args = args,
              stdin = not is_new,
              require_cwd = false,
            }
          end
        }
      })
    end
  }
}
