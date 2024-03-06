return {
	{
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
		lazy = true,
	},
	-- {
	-- 	"mxsdev/nvim-dap-vscode-js",
	-- 	lazy = true,
	-- 	requires = {
	-- 		"mfussenegger/nvim-dap",
	-- 		"vscode-js-debug",
	-- 	},
	-- 	-- opts = {
	-- 	--   debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
	-- 	-- }
	-- 	config = function()
	-- 		local dap = require("dap")
	-- 		require("dap-vscode-js").setup({
	-- 			node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
	-- 			debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
	-- 			adapters = { "pwa-node" }, -- which adapters to register in nvim-dap
	-- 		})
	-- 		for _, language in ipairs({ "typescript", "javascript" }) do
	-- 			dap.configurations[language] = {
	-- 				{
	-- 					type = "pwa-node",
	-- 					request = "launch",
	-- 					name = "Launch file",
	-- 					program = "${file}",
	-- 					cwd = "${workspaceFolder}",
	-- 				},
	-- 				{
	-- 					type = "pwa-node",
	-- 					request = "attach",
	-- 					name = "Attach",
	-- 					processId = require("dap.utils").pick_process,
	-- 					cwd = "${workspaceFolder}",
	-- 				},
	-- 			}
	-- 		end
	-- 	end,
	-- },
}
