return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match) or args.match
          pcall(function()
            require("nvim-treesitter").install({ lang }):wait(30000)
          end)
          pcall(vim.treesitter.start)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
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
