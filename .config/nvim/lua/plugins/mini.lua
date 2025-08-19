return {
  {
    'echasnovski/mini.ai',
    version = false,
    config = function()
      require('mini.ai').setup()
    end
  },
  {
    'echasnovski/mini.operators',
    version = false,
    config = function()
      require('mini.operators').setup()
    end
  },
  {
    'echasnovski/mini.move',
    version = false,
    config = function()
      require('mini.move').setup({
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = '<Left>',
          right = '<Right>',
          down = '<Down>',
          up = '<Up>',

          -- Move current line in Normal mode
          line_left = '<Left>',
          line_right = '<Right>',
          line_down = '<Down>',
          line_up = '<Up>',
        },
      })
    end
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require('mini.pairs').setup()
    end
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('mini.surround').setup()
    end
  },
  {
    'echasnovski/mini.bracketed',
    version = false,
    config = function()
      require('mini.bracketed').setup()
    end
  },
  {
    'echasnovski/mini.files',
    version = false,
    config = function()
      local mini_files = require("mini.files")

      mini_files.setup({
        mappings = {
          go_in_plus = "<Enter>",
          go_out_plus = "-",
          close = "<Esc>",
          synchronize = "<C-y>"
        },
      })

      -- dotnet template
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set("n", "<leader>a", function()
            local entry = require("mini.files").get_fs_entry()
            if entry == nil then
              vim.notify("No fd entry in mini files", vim.log.levels.WARN)
              return
            end
            local target_dir = entry.path
            if entry.fs_type == "file" then
              target_dir = vim.fn.fnamemodify(entry.path, ":h")
            end
            require("easy-dotnet").create_new_item(target_dir)
          end, { buffer = buf_id, desc = "Create file from dotnet template" })
        end,
      })
    end
  },
  {
    'echasnovski/mini.jump',
    version = false,
    config = function()
      require('mini.jump').setup()
    end
  },
}
