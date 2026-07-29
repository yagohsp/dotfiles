return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = { "BufReadPost", "FileType" },
    branch = "main",
    config = function()
      local parsers = require("nvim-treesitter.parsers")
      local can_install = vim.fn.executable("tree-sitter") == 1

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match) or args.match
          if not lang or not parsers[lang] then
            return
          end

          if vim.treesitter.language.add(lang) then
            pcall(vim.treesitter.start, args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            return
          end

          if not can_install then
            return
          end

          vim.schedule(function()
            pcall(function()
              require("nvim-treesitter").install({ lang })
            end)
          end)
        end,
      })
    end,
  },
  {
    "catgoose/nvim-colorizer.lua",
    lazy = true,
    event = { "BufReadPost", "FileType" },
    ft = { "css", "scss", "html", "javascript" },
    config = function()
      require("colorizer").setup({
        css = { rgb_fn = true },
        scss = { rgb_fn = true },
        html = { rgb_fn = true },
        javascript = { rgb_fn = true },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup({
        indent = {
          char = " ",
        },
        scope = {
          char = "▎",
          highlight = "Whitespace",
        },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
