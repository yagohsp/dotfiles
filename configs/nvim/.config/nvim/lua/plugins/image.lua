return {
  {
    "3rd/image.nvim",
    lazy = true,
    ft = { "markdown", "md" },
    build = false,
    opts = {
      processor = "magick_cli",
      tmux_show_only_in_active_window = true
    }
  }
}
