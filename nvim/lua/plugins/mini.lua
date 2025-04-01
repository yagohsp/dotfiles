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
            require('mini.files').setup({
                mappings = {
                    go_in_plus = "<Enter>",
                    go_out_plus = "-",
                    close = "<Esc>"
                },
                windows = {
                    -- preview = true,
                    -- width_preview = 100,
                    -- max_number = 3,
                }
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
