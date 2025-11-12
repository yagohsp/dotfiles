return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      "BurntSushi/ripgrep",
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local select_one_or_multi = function(prompt_bufnr)
        print("sim")
        local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        if not vim.tbl_isempty(multi) then
          require('telescope.actions').close(prompt_bufnr)
          for _, j in pairs(multi) do
            if j.path ~= nil then
              vim.cmd(string.format('%s %s', 'edit', j.path))
            end
          end
        else
          require('telescope.actions').select_default(prompt_bufnr)
        end
      end
      require('telescope').setup {
        defaults = {
          mappings = {
            n = {
              ["<CR>"] = select_one_or_multi
            },
            i = {
              ["<CR>"] = select_one_or_multi
            },
          },
          file_ignore_patterns = { ".git/" },
        },
        pickers = {
          find_files = {
            hidden = true
          }
        },
      }
    end
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },
}
