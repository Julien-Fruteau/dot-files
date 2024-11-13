return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		-- "rcarriga/nvim-notify",
	},
	--  optional = true,
	-- opts = {
	-- 	presets = {
	-- 		inc_rename = true,
	-- 	},
	-- 	routes = {
	-- 	-- require("lualine").setup({
	-- 	-- 	sections = {
	-- 	-- 		lualine_x = {
	-- 	-- 			{
	-- 	-- 				require("noice").api.statusline.mode.get,
	-- 	-- 				cond = require("noice").api.statusline.mode.has,
	-- 	-- 				color = { fg = "#ff9e64" },
	-- 	-- 			},
	-- 	-- 		},
	-- 	-- 	},
	-- 	-- }),
	-- },
	opts = function(_, opts)
		table.insert(opts.routes, {
			filter = {
				event = "msg_show",
				kind = "",
				-- find = "written",
			},
			opts = { skip = true },
		})
		-- table.insert(opts.routes, {
		-- 	filter = {
		-- 		event = "notify",
		-- 		find = "",
		-- 	},
		-- 	opts = { skip = true },
		-- })
		table.insert(opts.routes, {
			filter = { event = "notify", find = "No information available" },
			opts = { skip = true },
		})
		table.insert(opts.routes, {
			filter = { error = true, find = "Pattern not found" },
			opts = { skip = true },
		})
		table.insert(opts.routes, {
			filter = { error = true, find = "kotlin_language_server" },
			opts = { skip = true },
		})
		table.insert(opts.routes, {
			filter = { warning = true, find = "jdtls" },
			opts = { skip = true },
		})
		-- opts.messages = {
		--   view = "mini"
		-- }
		-- opts.popupmenu = {
		--   view = "mini"
		-- }
		-- opts.notify = {
		--   enabled = false
		-- }
	end,
}
