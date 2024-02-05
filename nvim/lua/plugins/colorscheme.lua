-- catppuccin
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
		opts = { flavour = "macchiato" }, -- latte, frappe, macchiato, mocha }
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
}

-- -- tokyonight
-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = true,
-- 	priority = 1000,
-- 	opts = { style = "storm" },
-- }

-- -- onedark
-- return {
-- 	{ "navarasu/onedark.nvim", priority = 1000 },
-- 	{
-- 		"LazyVim/LazyVim",
-- 		opts = {
-- 			colorscheme = "onedark",
-- 		},
-- 	},
-- }
--

-- -- kanagawa
-- return {
-- 	{ "rebelot/kanagawa.nvim", priority = 1000 },
-- 	{
-- 		"lazyVim/LazyVim",
-- 		opts = {
-- 			colorscheme = "kanagawa",
-- 		},
-- 	},
-- }
