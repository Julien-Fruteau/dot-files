return {
	{ "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
	{
		"iamcco/markdown-preview.nvim",
		lazy = false, -- to enable which key correctly
		keys = {
			{ "<leader>cMp", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown Preview" } },
		},
	},
	-- which key integration: see plugins/which-key.lua
	-- {
	-- 	"folke/which-key.nvim",
	-- 	optional = true,
	-- 	opts = {
	-- 		defaults = {
	-- 			["<leader>cM"] = { name = "+markdown" },
	-- 		},
	-- 	},
	-- },
}
