return {
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				keymaps = {
					["<C-p>"] = false,
				},
			})
		end,
	},
}
