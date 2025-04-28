return {
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        color_overrides = {
          mocha = {
            rosewater = "#f5e0dc",
            flamingo = "#f2cdcd",
            pink = "#f5c2e7",
            mauve = "#cba6f7",
            red = "#f38ba8",
            maroon = "#eba0ac",
            peach = "#fab387",
            yellow = "#f9e2af",
            green = "#a6e3a1",
            teal = "#94e2d5",
            sky = "#89dceb",
            sapphire = "#74c7ec",
            -- blue = "#89b4fa",
            blue = "#cba6f7",
            lavender = "#b4befe",
            text = "#cdd6f4",
            subtext1 = "#bac2de",
            subtext0 = "#a6adc8",
            overlay2 = "#9399b2",
            overlay1 = "#7f849c",
            overlay0 = "#6c7086",
            surface2 = "#585b70",
            surface1 = "#45475a",
            surface0 = "#313244",
            base = "#1e1e2e",
            mantle = "#181825",
            crust = "#11111b",
          },
          latte = {
            -- rosewater = "#762B1A", -- "#dc8a78"
            -- flamingo = "#700303",  -- "#dd7878"
            -- pink = "#93257B",      -- "#ea76cb"
            -- mauve = "#692CB8",     -- "#8839ef"
            -- red = "#5E0F04",       -- "#d20f39"
            -- maroon = "#87000C",    -- "#e64553"
            -- peach = "#823000",     -- "#fe640b"
            -- yellow = "#957C16",    -- "#df8e1d"
            -- green = "#0E3F0A",     -- "#40a02b"
            -- teal = "#1D7277",      -- "#179299"
            -- sky = "#0F5875",       -- "#04a5e5"
            -- sapphire = "#0E6A62",  -- "#209fb5"
            -- blue = "#173079",      --"#1e66f5"
            -- lavender = "#3E50AC",  -- "#7287fd"
            -- text = "#4c4f69",
            --
            -- subtext1 = "#262422", -- "#5c5f77"
            -- subtext0 = "#353330", -- "#6c6f85"
            -- overlay2 = "#45413E", -- "#7c7f93"
            -- overlay1 = "#54504C", -- "#8c8fa1"
            -- overlay0 = "#635E59", -- "#9ca0b0"
            -- surface2 = "#726D67", -- "#acb0be"
            -- surface1 = "#827B75", -- "#bcc0cc"
            -- surface0 = "#918A83", -- "#ccd0da"
            base = "#E9E2C9",   -- "#eff1f5"
            mantle = "#DBD2B9", -- "#e6e9ef"
            crust = "#BDB6A6",  -- "#dce0e8"
          }
        }
      })
    end,
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      local logo = [[

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣴⣶⣶⣶⣶⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⡿⣟⣯⣽⣷⣶⠶⠾⢯⡻⣿⡿⠛⠉⠙⢲⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⢫⣾⣿⡿⠋⠉⢀⣀⣀⣀⠈⠘⠀⠀⠀⠀⠀⠱⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣰⡿⣽⣿⣳⣿⣿⡟⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⡀⢸⣻⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣰⡟⣼⣿⢳⣿⣿⣿⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣣⠀⢋⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣿⢱⣿⡏⣿⣿⣿⡏⣜⢫⣭⣉⠭⢭⣿⣛⣿⠿⠿⢫⣵⠎⠚⢿⡆⠸⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⣿⣿⢳⣿⣿⣿⣧⢿⡾⣿⡁⠀⠀⣾⣿⢸⣿⣿⣞⢿⣦⣤⠼⡇⢰⢹⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣾⣿⢫⣝⣾⣿⣿⣿⣿⡜⣷⣝⣛⣓⣛⣻⣯⣿⣿⣿⣿⣿⣶⣿⣿⠃⣼⣾⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢿⣿⣎⡻⢹⣿⣿⣿⣿⣷⢻⣿⣿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⠏⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣧⢿⡟⣾⣿⣿⡏⣿⣿⣼⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⠿⣁⣠⠘⠿⠇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠘⣿⡸⡇⣿⣿⣿⠃⣿⡟⠈⠙⠛⠿⢿⣿⡿⠿⢿⣟⣻⡥⣴⣶⡾⠛⠻⢷⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⡇⣿⡜⣿⢏⣇⡿⠣⠄⡀⣀⢠⡍⣷⢸⣿⣿⣿⣿⡧⣿⣿⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⡇⣿⣿⡈⣾⡏⣾⣿⣿⢿⣙⣛⣯⣬⣼⣿⣿⣿⣿⣿⢿⣿⣦⣄⣠⣴⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⢿⣿⣿⣷⢹⡇⣿⣿⣿⣿⣿⣿⠿⣿⣿⣛⣿⣯⣽⣿⡿⣿⣿⣿⡋⣻⣿⡷⠁⠀⠀⠀⠀
⠀⠀⠀⠀⣸⡿⢿⣿⡟⣿⡇⡇⠙⣿⣷⣶⣿⣿⠿⠿⠟⣛⣛⣛⡛⠉⠭⠝⠻⠿⠿⠿⠛⠈⠀⠀⠀⠀⠀
⠀⠀⠀⢠⠋⠀⢸⣿⠇⠈⠋⡅⢸⣘⣛⣛⣛⣋⣩⣭⣭⣭⣤⣄⠀⠀⠀⠆⣶⢶⠁⠀⠀⠀⠀⠀⠀⠀⠀
]]

      require('dashboard').setup {
        config = {
          header = vim.split(logo, "\n"),
          packages = { enable = false },
          shortcut = {
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              desc = ' Dotfiles',
              group = 'Number',
              action = 'Telescope dotfiles',
              key = 'd',
            },
          }
        }
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
        sections = {
          -- lualine_a = { "mode" },
          lualine_a = {},
          -- lualine_b = { "branch", "diff", "diagnostics" },
          lualine_b = {},
          lualine_c = { "buffers" },
          lualine_x = { "filetype" },
          lualine_y = {},
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          -- lualine_c = { "filename" },
          lualine_c = {},
          -- lualine_x = { "location" },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
  {
    "VonHeikemen/fine-cmdline.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("fine-cmdline").setup({
        popup = {
          position = {
            row = "80%",
          },
          size = {
            width = "40%",
          },
        },
      })
    end,
  },
  {
    "xiyaowong/transparent.nvim",
  },
  {
    "max397574/colortils.nvim",
    cmd = "Colortils",
    config = function()
      require("colortils").setup()
    end,
  }
}
