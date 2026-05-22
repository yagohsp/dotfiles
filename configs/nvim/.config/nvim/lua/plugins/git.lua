vim.keymap.set("n", "<A-b>", '<cmd>GitBlameToggle<cr>', { noremap = true, silent = true, desc = "Show git blame" })

return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false,
      message_template = "<author> • <date> • <summary>",
      date_format = "%m-%d-%Y",
      virtual_text_column = 1,
    },
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
    config = function()
      -- vim.g.lazygit_floating_window_use_plenary = 0
      -- vim.g.lazygit_use_neovim_remote = 0

      vim.api.nvim_create_autocmd("TabClosed", {
        callback = function()
          -- Find the lazygit terminal buffer and restore focus
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf):match("lazygit") then
              vim.api.nvim_set_current_buf(buf)
              break
            end
          end
        end,
      })
    end
  },
}
