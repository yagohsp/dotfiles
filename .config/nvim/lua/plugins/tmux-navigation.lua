return {
  'alexghergh/nvim-tmux-navigation',
  config = function()
    require 'nvim-tmux-navigation'.setup {
      keybindings = {
        up = "<A-k>",
        down = "<A-j>",
        right = "<A-l>",
        left = "<A-h>",
      }
    }
  end
}
