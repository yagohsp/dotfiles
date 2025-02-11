return {
    'alexghergh/nvim-tmux-navigation',
    config = function()
        require 'nvim-tmux-navigation'.setup {
            keybindings = {
                left = "<C-A-h>",
                down = "<C-A-j>",
                up = "<C-A-k>",
                right = "<C-A-l>",
            }
        }
    end
}
