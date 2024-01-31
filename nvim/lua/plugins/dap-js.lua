return {
	{
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    lazy = true,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
    lazy = true,
		requires = {
			"mfussenegger/nvim-dap",
			"vscode-js-debug",
		},
    -- opts = {
    --   debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
    -- }
		config = function()
      local dap = require('dap')
			require("dap-vscode-js").setup({
				node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        -- debugger_cmd = { 'js-debug-adapter' },
				adapters = {  "pwa-node" }, -- which adapters to register in nvim-dap
				-- log_file_path = "(stdpath cache)/dap_vscode_js.log", -- Path for file logging
				-- log_file_level = vim.log.levels.DEBUG,-- Logging level for output to file. Set to false to disable file logging.
				-- log_console_level = vim.log.levels.TRACE -- Logging level for output to console. Set to false to disable console output.
			})

			for _, language in ipairs({ "typescript", "javascript" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end,
	},
}
