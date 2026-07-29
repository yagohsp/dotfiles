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
      local function close_lazygit()
        if vim.g.lazygit_opened ~= 1 then
          return
        end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "lazygit" then
            local chan = vim.bo[buf].channel
            if chan and chan > 0 then
              pcall(vim.fn.jobstop, chan)
            end
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
            break
          end
        end
        vim.g.lazygit_opened = 0
        if _G.LAZYGIT_LOADED ~= nil then
          _G.LAZYGIT_LOADED = false
        end
        _G.LAZYGIT_BUFFER = nil
        pcall(vim.cmd, "wincmd p")
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lazygit",
        callback = function(event)
          local buf = event.buf
          vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            vim.keymap.set("t", "<Esc>", close_lazygit, {
              buffer = buf,
              silent = true,
              nowait = true,
              desc = "Close LazyGit",
            })
            vim.keymap.set("n", "<Esc>", close_lazygit, {
              buffer = buf,
              silent = true,
              nowait = true,
              desc = "Close LazyGit",
            })
          end, 50)
        end,
      })

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
