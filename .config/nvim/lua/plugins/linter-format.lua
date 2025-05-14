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
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
    end
  }
}
