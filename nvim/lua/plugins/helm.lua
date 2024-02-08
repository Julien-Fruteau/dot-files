return {
	{ "mrjosh/helm-ls", dependencies = {
		"towolf/vim-helm",
		ft = "helm",
	} },
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				helm_ls = {
					setup = {
						-- settings = {
						-- 	["helm-ls"] = {
						-- 		yamlls = {
						-- 			path = "yaml-language-server",
						-- 		},
						-- 	},
						-- },
						default_config = {
							cmd = { "helm_ls", "serve" },
							filetypes = { "helm" },
							root_dir = function(fname)
								return require("lspconfig.util").root_pattern("Chart.yaml")(fname)
							end,
						},
					},
				},
			},
		},
	},
}
