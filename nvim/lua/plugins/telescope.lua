-- See `:help telescope` and `:help telescope.setup()`
return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"dawsers/telescope-file-history.nvim",
		{
			"ahmedkhalf/project.nvim",
			opts = {
				manual_mode = true,
			},
			event = "VeryLazy",
			config = function(_, opts)
				require("project_nvim").setup(opts)
				require("lazyvim.util").on_load("telescope.nvim", function()
					require("telescope").load_extension("projects")
				end)
			end,
			keys = {
				{ "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
			},
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local file_history = require("file_history")

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						-- ['<C-u>'] = false,
						-- ['<C-d>'] = false,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		file_history.setup({
			-- This is the location where it will create your file history repository
			backup_dir = "~/.file-history-git",
			-- command line to execute git
			git_cmd = "git",
		})
		telescope.load_extension("file_history")

		-- -- set keymaps
		-- local keymap = vim.keymap -- for conciseness
		--
		-- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		-- keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		-- keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		-- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
	end,
}
