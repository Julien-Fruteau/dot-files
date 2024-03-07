return {
	"nvim-treesitter/nvim-treesitter",
	-- enriche default config https://www.lazyvim.org/plugins/treesitter
	opts = function(_, opts)
		vim.list_extend(opts.ensure_installed, {
			"go",
			"gomod",
			"gowork",
			"gosum",
		})
		opts.textobjects = {
			lsp_interop = {
				border = "none",
				disable = {},
				enable = false,
				floating_preview_opts = {},
				module_path = "nvim-treesitter.textobjects.lsp_interop",
				peek_definition_code = {},
			},
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
				goto_next_end = {
					["]C"] = "@class.outer",
					["]F"] = "@function.outer",
				},
				goto_next_start = {
					["]c"] = "@class.outer",
					["]f"] = "@function.outer",
				},
				goto_previous_end = {
					["[C"] = "@class.outer",
					["[F"] = "@function.outer",
				},
				goto_previous_start = {
					["[c"] = "@class.outer",
					["[f"] = "@function.outer",
				},
				goto_next = {
					["]i"] = "@conditional.inner",
					["]p"] = "@parameter.inner",
				},
				goto_previous = {
					["[i"] = "@conditional.inner",
					["[p"] = "@parameter.inner",
				},
				loaded = true,
				module_path = "nvim-treesitter.textobjects.move",
			},
			swap = {
				module_path = "nvim-treesitter.textobjects.swap",
				enable = true,
				swap_next = {
					["<leader>cp"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>cP"] = "@parameter.inner",
				},
			},
		}
	end,
}
