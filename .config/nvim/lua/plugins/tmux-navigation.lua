return {
    'alexghergh/nvim-tmux-navigation',
    config = function()
        require 'nvim-tmux-navigation'.setup {
            keybindings = {
                up = "<C-k>",
                down = "<C-j>",
                right = "<C-l>",
                left = "<C-h>",
            }
        }
    end
}
