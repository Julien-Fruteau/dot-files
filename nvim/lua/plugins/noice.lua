return {
	"folke/noice.nvim",
	opts = function(_, opts)
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
      filter = { warning = true, find = "Client jdtls quit with exit code 1 and signal 0" },
      opts = { skip = true },
    })
	end,
}
