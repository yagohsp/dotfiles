return {
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
  },
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    version = "*",
    keys = {
      {
        "<leader>v",
        function() require("oklch-color-picker").pick_under_cursor() end,
        desc = "Color pick under cursor",
      },
    },
    ---@type oklch.Opts
    opts = {},
  }
}
