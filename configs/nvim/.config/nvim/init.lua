vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.cmd([[
    augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=150})
    augroup END
]])


vim.opt.termguicolors = true

-- Before plugins load (deprecation warnings can fire during lazy.setup).
vim.deprecate = function() end

require("lazy").setup(
  "plugins",
  {
    change_detection = {
      notify = false
    },
  }
)
require("options")
require("project_picker").setup()
-- vim.cmd("colorscheme frost")
