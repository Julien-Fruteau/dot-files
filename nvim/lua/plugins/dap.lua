local js_based_languages = {
	"typescript",
	"javascript",
	"typescriptreact",
	"javascriptreact",
	"vue",
}
return {
	{
		"Mgenuit/nvim-dap-kotlin",
		config = function()
			require("dap-kotlin").setup({
				dap_command = "target/intranet-0.0.1-SNAPSHOT.jar",
				project_root = "${workspaceFolder}",
			})
		end,
	},
}
-- return {
-- 	-- {
-- 	-- 	"yriveiro/dap-go.nvim",
-- 	-- },
-- 	-- 	requires = {
-- 	-- 		"mfussenegger/nvim-dap",
-- 	-- 	},
-- 	-- 	config = function()
-- 	-- 		require("dap-go").setup({
-- 	-- 			external_config = {
-- 	-- 				enable = true,
-- 	-- 			},
-- 	-- 		})
-- 	-- 	end,
-- 	-- },
-- 	{
-- 		"leoluz/nvim-dap-go",
-- 		-- config = true,
-- 		requires = {
-- 			"yriveiro/dap-go.nvim",
-- 		},
-- 		config = function()
-- 			require("dap-go").setup()
-- 		end,
-- 	},
--   -- NOTE : not working easily. use node --inspect and attach process, break points seems to work
--
-- 	-- {
-- 	-- 	"microsoft/vscode-js-debug",
-- 	-- 	build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
-- 	-- 	-- lazy = true,
-- 	-- },
-- 	-- {
-- 	-- 	"mxsdev/nvim-dap-vscode-js",
-- 	-- 	-- lazy = true,
-- 	-- 	requires = {
-- 	-- 		"mfussenegger/nvim-dap",
-- 	-- 		"vscode-js-debug",
-- 	-- 	},
-- 	-- 	-- opts = {
-- 	-- 	--   debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
-- 	-- 	-- }
-- 	-- 	config = function()
-- 	-- 		local dap = require("dap")
-- 	-- 		require("dap-vscode-js").setup({
-- 	-- 			debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
-- 	-- 			adapters = {
-- 	-- 				"chrome",
-- 	-- 				"pwa-node",
-- 	-- 				"pwa-chrome",
-- 	-- 				"pwa-msedge",
-- 	-- 				"pwa-extensionHost",
-- 	-- 				"node-terminal",
-- 	--          "node"
-- 	-- 			},
-- 	-- 		})
-- 	-- 		for _, language in ipairs(js_based_languages) do
-- 	-- 			dap.configurations[language] = {
-- 	-- 				-- Debug single nodejs files
-- 	-- 				{
-- 	-- 					type = "pwa-node",
-- 	-- 					request = "launch",
-- 	-- 					name = "Launch file",
-- 	-- 					program = "${file}",
-- 	-- 					cwd = vim.fn.getcwd(),
-- 	-- 					sourceMaps = true,
-- 	-- 				},
-- 	-- 				-- Debug nodejs processes (make sure to add --inspect when you run the process)
-- 	-- 				{
-- 	-- 					type = "pwa-node",
-- 	-- 					request = "attach",
-- 	-- 					name = "Attach",
-- 	-- 					processId = require("dap.utils").pick_process,
-- 	-- 					cwd = vim.fn.getcwd(),
-- 	-- 					sourceMaps = true,
-- 	-- 				},
-- 	-- 				-- Debug web applications (client side)
-- 	-- 				{
-- 	-- 					type = "pwa-chrome",
-- 	-- 					request = "launch",
-- 	-- 					name = "Launch & Debug Chrome",
-- 	-- 					url = function()
-- 	-- 						local co = coroutine.running()
-- 	-- 						return coroutine.create(function()
-- 	-- 							vim.ui.input({
-- 	-- 								prompt = "Enter URL: ",
-- 	-- 								default = "http://localhost:3000",
-- 	-- 							}, function(url)
-- 	-- 								if url == nil or url == "" then
-- 	-- 									return
-- 	-- 								else
-- 	-- 									coroutine.resume(co, url)
-- 	-- 								end
-- 	-- 							end)
-- 	-- 						end)
-- 	-- 					end,
-- 	-- 					webRoot = vim.fn.getcwd(),
-- 	-- 					protocol = "inspector",
-- 	-- 					sourceMaps = true,
-- 	-- 					userDataDir = false,
-- 	-- 				},
-- 	-- 				-- -- Divider for the launch.json derived configs
-- 	-- 				-- {
-- 	-- 				-- 	name = "----- ↓ launch.json configs ↓ -----",
-- 	-- 				-- 	type = "",
-- 	-- 				-- 	request = "launch",
-- 	-- 				-- },
-- 	-- 			}
-- 	-- 		end
-- 	-- 	end,
-- 	-- },
-- 	{
-- 		"Joakker/lua-json5",
-- 		build = "./install.sh",
-- 	},
-- }
