return {
	"nvim-treesitter/nvim-treesitter",
	-- enriche default config https://www.lazyvim.org/plugins/treesitter
	opts = {
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					["ii"] = "@conditional.inner",
					["ai"] = "@conditional.outer",
					["il"] = "@loop.inner",
					["al"] = "@loop.outer",
					["at"] = "@comment.outer",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next = {
					["]i"] = "@conditional.inner",
					["]p"] = "@parameter.inner",
				},
				goto_previous = {
					["[i"] = "@conditional.inner",
					["[p"] = "@parameter.inner",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>cp"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>cP"] = "@parameter.inner",
				},
			},
		},
	},
}
