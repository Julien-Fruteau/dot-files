return {
	"max397574/better-escape.nvim",
	config = function()
		-- lua, default settings
		require("better_escape").setup({
			timeout = vim.o.timeoutlen,
			default_mappings = true,
			mappings = {
				i = {
					j = {
						-- These can all also be functions
						k = "<Esc>",
						-- j = "<Esc>",
					},
				},
				c = {
					j = {
						k = "<Esc>",
						-- j = "<Esc>",
					},
				},
				t = {
					j = {
						k = "<Esc>",
						-- j = "<Esc>",
					},
				},
				v = {
					j = {
						k = "<Esc>",
					},
				},
				s = {
					j = {
						k = "<Esc>",
					},
				},
			},
		})
	end,
	-- 	require("better_escape").setup({
	-- 		i = {
	-- 			["j"] = {
	-- 				["j"] = function()
	-- 					return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
	-- 				end,
	-- 			},
	-- 		},
	-- 	})
	-- end,
}
