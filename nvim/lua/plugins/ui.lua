return {
	"nvimdev/dashboard-nvim",
  dependencies = { {'nvim-tree/nvim-web-devicons'}},
	event = "VimEnter",
	opts = function(_, opts)
		local logo = [[
      █████╗ ██╗  ██╗██╗ ██╗██████╗ 
      ██╔══██╗██║  ██║╚═╝██╔╝╚════██╗
      ╚█████╔╝███████║  ██╔╝  █████╔╝
      ██╔══██╗╚════██║ ██╔╝  ██╔═══╝ 
      ╚█████╔╝     ██║██╔╝██╗███████╗
      ╚════╝      ╚═╝╚═╝ ╚═╝╚══════╝

      ]]

		logo = string.rep("\n", 8) .. logo .. "\n\n"
		opts.config.header = vim.split(logo, "\n")
	end,
}
