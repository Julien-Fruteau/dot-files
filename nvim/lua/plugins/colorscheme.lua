-- catppuccin
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = { flavour = "macchiato" }, -- latte, frappe, macchiato, mocha }
	},
	{ "navarasu/onedark.nvim", priority = 1000 },
	{ "rebelot/kanagawa.nvim", priority = 1000 },
	{ "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000 },
	{ "romainl/Apprentice", priority = 1000 },
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = { style = "moon" }, -- storm, night, moon, day
	},
  {
    'drewtempelmeyer/palenight.vim',
  }
}
