return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			-- no_italic = false,
			-- term_colors = true,
			-- flavour = "frappe",
			flavour = "macchiato",
			-- flavour = "mocha",
			-- transparent_background = true,
			-- dim_inactive = {
			-- 	enabled = true, -- dims the background color of inactive window
			-- 	shade = "dark",
			-- 	percentage = 0.1, -- percentage of the shade to apply to the inactive window
			-- },
			color_overrides = {
				all = {
					cursor = "#cba6f7", -- use a mauve-ish purple instead of default pink
					-- rosewater = "#cba6f7", -- use a mauve-ish purple instead of default pink
					-- red = "#cba6f7", -- use a mauve-ish purple instead of default pink
					-- color5 = "#cba6f7", -- use a mauve-ish purple instead of default pink
					pink = "#cba6f7", -- use a mauve-ish purple instead of default pink
				},
			},
		}, -- latte, frappe, macchiato, mocha }
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {
			style = "moon",
		}, -- storm, night, moon, day
		lazy = false,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				variant = "moon",
				dark_variant = "moon",
				dim_inactive_windows = true,
				styles = {
					bold = false,
					italic = false,
					transparency = false,
				},
			})
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
	},
}
