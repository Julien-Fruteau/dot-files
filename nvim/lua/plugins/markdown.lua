return {
	{ "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
	{
		"iamcco/markdown-preview.nvim",
		keys = {
			{ "<leader>cMp", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown Preview" } },
		},
	},
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			defaults = {
				["<leader>cM"] = { name = "+markdown" },
			},
		},
	},
}
