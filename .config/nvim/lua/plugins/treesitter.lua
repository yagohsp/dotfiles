return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup {
        indent = {
          char = " ",
        },
        scope = {
          char = "▎",
          highlight = "Whitespace"
        }
      }
    end
  },
  "windwp/nvim-ts-autotag",
  config = function()
    require('nvim-ts-autotag').setup()
  end
}
