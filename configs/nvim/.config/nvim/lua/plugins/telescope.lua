return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      "BurntSushi/ripgrep",
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local actions = require("telescope.actions")

      -- Show dotfiles (e.g. .gitignore); skip common generated / VCS dirs.
      local generated_dir_names = {
        ".git",
        ".cache",
        ".npm",
        ".yarn",
        ".pnpm-store",
        ".next",
        ".nuxt",
        ".turbo",
        ".parcel-cache",
        ".pytest_cache",
        ".mypy_cache",
        ".ruff_cache",
        ".hypothesis",
        ".tox",
        ".gradle",
        ".idea",
        "node_modules",
        "__pycache__",
      }

      local file_ignore_patterns = {}
      for _, name in ipairs(generated_dir_names) do
        file_ignore_patterns[#file_ignore_patterns + 1] = "/" .. name:gsub("%.", "%%.") .. "/"
      end

      local function find_files_command(_opts)
        if vim.fn.executable("fd") == 1 then
          local cmd = { "fd", "--type", "f", "--hidden", "--color", "never" }
          for _, name in ipairs(generated_dir_names) do
            cmd[#cmd + 1] = "--exclude"
            cmd[#cmd + 1] = name
          end
          return cmd
        end
        if vim.fn.executable("fdfind") == 1 then
          local cmd = { "fdfind", "--type", "f", "--hidden", "--color", "never" }
          for _, name in ipairs(generated_dir_names) do
            cmd[#cmd + 1] = "--exclude"
            cmd[#cmd + 1] = name
          end
          return cmd
        end
        return { "rg", "--files", "--hidden", "--color", "never" }
      end

      local select_one_or_multi = function(prompt_bufnr)
        local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        if not vim.tbl_isempty(multi) then
          actions.close(prompt_bufnr)
          for _, j in pairs(multi) do
            if j.path ~= nil then
              vim.cmd(string.format('%s %s', 'edit', j.path))
            end
          end
        else
          actions.select_default(prompt_bufnr)
        end
      end
      local telescope = require("telescope")
      telescope.setup {
        defaults = {
          mappings = {
            n = {
              ["<CR>"] = select_one_or_multi
            },
            i = {
              ["<CR>"] = select_one_or_multi,
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = file_ignore_patterns,
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = find_files_command,
          },
        },
      }

      vim.keymap.set('v', '<leader>f', function()
        vim.cmd('normal! "zy')
        local selection = vim.fn.getreg('z')
        require('telescope.builtin').live_grep({ default_text = selection })
      end, { noremap = true, silent = true })
    end
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },
}
