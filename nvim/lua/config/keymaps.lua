local keymap = vim.keymap -- for conciseness

-- Additional Keymaps to defaults https://www.lazyvim.org/keymaps -------------------
-- telescope shortcuts : https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#usage

-- cheatsheet

-- write all buffers :wa
--
-- -- case or not to case, that is the question
-- ~    : Changes the case of current character
--  guu  : Change current line from upper to lower.
--  gUU  : Change current LINE from lower to upper.
--  guw  : Change to end of current WORD from upper to lower.
--  guaw : Change all of current WORD to lower.
--  gUw  : Change to end of current WORD from lower to upper.
--  gUaw : Change all of current WORD to upper.
--  g~~  : Invert case to entire line
--  g~w  : Invert case to current WORD
keymap.set("n", "<leader>cc", "g~w", { desc = "Case word: invert" })
--  guG  : Change to lowercase until the end of document.
--  gU)  : Change until end of sentence to upper case
--  gu}  : Change to end of paragraph to lower case
--  gU5j : Change 5 lines below to upper case
--  gu3k : Change 3 lines above to lower case
--

-- lookup word
keymap.set("n", "<leader>fw", "g*N", { desc = "Lookup word" })
--
-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
-- keymap.set("n", "dw", "vb_d", { desc = "Delete a word backward" })
-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement
keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- window management
keymap.set("n", "sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
-- keymap.set("n", "ss", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", { desc = "Continue below" })
keymap.set("n", "<Leader>O", "O<Esc>^Da", { desc = "Continue above" })

-- New tab
keymap.set("n", "te", ":tabedit")
-- keymap.set("n", "<tab>", ":tabnext<Return>", opts)
-- keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

keymap.set("n", "<leader>sx", "<CMD>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<CMD>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<CMD>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<CMD>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<CMD>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<CMD>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- buffer management
keymap.set("n", "<M-w>", ":b#<CR>", { desc = "Focus to previous active buffer" }) --  Focus to previous active buffer

keymap.set("n", "<leader>fs", "<CMD>w<CR>", { desc = "File save" }) -- file save, NB: by default lazyvim put it to C-s

-- neo-tree
keymap.set("n", "<leader>e", ":Neotree focus<cr>", { desc = "Explorer focus on File Explorer" })
-- keymap.set("n", "<leader>E", ":Neotree toggle<cr>", { desc = "Explorer toggle File Explorer" })

-- gitsigns
-- git toggle blame line
keymap.set("n", "<leader>gl", ":Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle git blame line" })

-- git-worktree
keymap.set(
	"n",
	"<leader>gr",
	"<CMD>lua require('telescope').extensions.git_worktree.git_worktree()<CR>",
	{ desc = "Switch between worktree" }
)
-- -- <Enter> - switches to that worktree
-- <c-d> - deletes that worktree
-- <c-f> - toggles forcing of the next deletion
keymap.set(
	"n",
	"<leader>gR",
	"<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
	{ desc = "Create worktree" }
)
-- show current buffer commits
keymap.set("n", "<leader>gb", "<CMD>Telescope git_bcommits<CR>", { desc = "Show current buffer commits" })

-- glow - markdown preview
keymap.set("n", "<leader>ug", "<CMD>Glow<CR>", { desc = "Preview markdown file" })
-- keymap.set("n", "<leader>cMp", "<CMD>MarkdownPreviewToggle<CR>", { desc = "Markdown Preview" })

-- maximiser
keymap.set("n", "<leader>wm", "<CMD>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })

-- dapui
keymap.set("n", "<leader>dd", "<CMD>DapShowLog<CR>", { desc = "Dap show logs" })

keymap.set("n", "<leader>dv", function()
	if vim.fn.filereadable(".vscode/launch.json") then
		require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "javascript", "typescript" } })
	end
	require("dap").continue()
end, { desc = "Extend pwa-node to js|ts config" })

keymap.set("n", "<leader>dF", function()
	if vim.fn.filereadable(".vscode/launch.json") then
		require("dap.ext.vscode").load_launchjs(nil, { ["firefox"] = { "javascript", "typescript" } })
	end
	require("dap").continue()
end, { desc = "Extend firefox to js|ts debug config" })

-- extend vscode config
-- problem is do not take into consideration envFile or other because
-- this depends on the dap-<language> configurations... :(
keymap.set("n", "<leader>dV", function()
	local launchFile = ".vscode/launch.json"
	local file = io.open(launchFile, "r")
	if not file then
		return
	end
	local content = file:read("*a")
	file:close()

	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local dap_vscode = require("dap.ext.vscode")
	local parse = require("json5").parse

	local data = parse(content)
	assert(data.configurations, "Launch.json must have a 'configurations' key")

	for _, config in ipairs(data.configurations) do
		assert(config.type, "Configuration in launch.json must have a 'type' key")
		dap_vscode.load_launchjs(nil, { [config.type] = { filetype } })
	end
	require("dap").continue()
end, { desc = "Run including vscode config" })

-- dap-go configurations
-- NOTE: not necessary since launchjs works with env (instead of envFile, at least for go)
keymap.set("n", "<leader>dG", function()
	local launchFile = "dap-go.json"
	local file = io.open(launchFile, "r")
	if not file then
		print("No dap-go.json file found")
		return
	end
	local content = file:read("*a")
	file:close()

	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local dap = require("dap")
	-- local dap_go = require("dap-go")
	local parse = require("json5").parse

	configurations = dap.configurations[filetype]
	local data = parse(content)
	for _, config in ipairs(data) do
		print(config.type)
		assert(config.type, "Configuration must have a 'type' key")
		assert(config.name, "Configuration must a have a 'name' key")
		for _, dap_config in pairs(configurations) do
			print(dap_config)
			if dap_config.name == config.name then
				table.remove(configurations, config)
			end
		end
		table.insert(configurations, config)
	end
	dap.configurations[filetype] = configurations
	require("dap").continue()
end, { desc = "Run including dap-go.json config" })
--
-- vscode
if vim.g.vscode then
	-- undo/REDO via vscode
	keymap.set("n", "u", [[<CMD>call VSCodeNotify('undo')<CR>]])
	keymap.set("n", "<C-r>", [[<CMD>call VSCodeNotify('redo')<CR>]])
end

keymap.set("n", "<leader>df", "<CMD>Telescope dap configurations<CR>", { desc = "Show dap configurations" })
