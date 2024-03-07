return {
	"nvim-neo-tree/neo-tree.nvim",
	config = function()
		require("neo-tree").setup({
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				filtered_items = {
					-- visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,
				},
			},
		})
	end,
}
