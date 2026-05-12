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
keymap.set("n", "<leader>cw", "g~w", { desc = "Case word: invert" })
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
keymap.set("n", "<A-v>", "<C-v>", { desc = "Visual block mode" })

-- paste do not overwrite the register
-- keymap.set("n", "p", "P", { desc = "Paste before selection by defaults to avoid overwriting register" })
keymap.set("n", "U", "<C-R>", { desc = "Redo" })

local function get_total_buffers()
	local buffers = vim.api.nvim_list_bufs()
	return #buffers
end

keymap.set("n", "<leader>wl", function()
	local current_win = vim.fn.winnr()
	local right_win = vim.fn.winnr("l")
	local buf = vim.api.nvim_get_current_buf()
	local total_buffers = get_total_buffers()
	if total_buffers < 2 then
		return
	end

	if current_win == right_win then
		-- No right split exists, create one
		vim.cmd("vsplit")
	end
	vim.cmd.wincmd("l")
	vim.cmd.buffer(buf)
	vim.cmd.wincmd("h")
	vim.cmd("b#")
	vim.cmd.wincmd("l")
end, { desc = "Move buffer to right split" })

keymap.set("n", "<leader>wL", function()
	local current_win = vim.fn.winnr()
	local right_win = vim.fn.winnr("l")
	local buf = vim.api.nvim_get_current_buf()
	local total_buffers = get_total_buffers()
	if total_buffers < 2 then
		return
	end

	if current_win == right_win then
		-- No right split exists, create one
		vim.cmd("vsplit")
	end
	vim.cmd.wincmd("l")
	vim.cmd.buffer(buf)
end, { desc = "Split buffer to right" })

keymap.set("n", "<leader>wh", function()
	local current_win = vim.fn.winnr()
	local right_win = vim.fn.winnr("h")
	local buf = vim.api.nvim_get_current_buf()
	local total_buffers = get_total_buffers()
	if total_buffers < 2 then
		return
	end

	if current_win == right_win then
		-- No right split exists, create one
		vim.cmd("vsplit")
	end
	vim.cmd.wincmd("h")
	vim.cmd.buffer(buf)
	vim.cmd.wincmd("l")
	vim.cmd("b#")
	vim.cmd.wincmd("h")
end, { desc = "Move buffer to left split" })

keymap.set("n", "<leader>wH", function()
	local current_win = vim.fn.winnr()
	local right_win = vim.fn.winnr("h")
	local buf = vim.api.nvim_get_current_buf()
	local total_buffers = get_total_buffers()
	if total_buffers < 2 then
		return
	end

	if current_win == right_win then
		-- No right split exists, create one
		vim.cmd("vsplit")
	end
	vim.cmd.wincmd("h")
	vim.cmd.buffer(buf)
end, { desc = "Split buffer to left" })

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", { desc = "Continue below" })
keymap.set("n", "<Leader>O", "O<Esc>^Da", { desc = "Continue above" })

-- New tab
-- keymap.set("n", "te", ":tabedit")
-- keymap.set("n", "<tab>", ":tabnext<Return>", opts)
-- keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>wx", "<CMD>close<CR>", { desc = "Close current split" }) -- close current split window

-- buffer management
keymap.set("n", "<M-w>", ":b#<CR>", { desc = "Focus to previous active buffer" }) --  Focus to previous active buffer

keymap.set("n", "<leader>fs", "<CMD>w<CR>", { desc = "File save" }) -- file save, NB: by default lazyvim put it to C-s

-- snack
keymap.set("n", "<leader>e", function()
	local explorer_win = nil

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft == "snacks_picker_list" then
			explorer_win = win
			break
		end
	end

	if vim.api.nvim_get_current_win() ~= explorer_win and explorer_win then
		vim.api.nvim_set_current_win(explorer_win)
	else
		Snacks.explorer()
	end
end, { desc = "Open Snack file explorer" })

-- noice
keymap.set("n", "<leader>snt", "<CMD>Telescope noice<CR>", { desc = "Telescope noice messages" })
keymap.set("n", "<M-l>", "<CMD>Noice dismiss<CR>", { desc = "Telescope noice messages" })

-- show current buffer commits
keymap.set("n", "<leader>gb", "<CMD>Telescope git_bcommits<CR>", { desc = "Show current buffer commits" })

-- maximiser
keymap.set("n", "<leader>wm", "<CMD>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })

-- dap
keymap.set("n", "<leader>dd", "<CMD>DapShowLog<CR>", { desc = "Dap show logs" })

keymap.set("n", "<leader>df", "<CMD>Telescope dap configurations<CR>", { desc = "Show dap configurations" })

-- vscode
if vim.g.vscode then
	-- undo/REDO via vscode
	keymap.set("n", "u", [[<CMD>call VSCodeNotify('undo')<CR>]])
	keymap.set("n", "<C-r>", [[<CMD>call VSCodeNotify('redo')<CR>]])
	keymap.set("n", "U", [[<CMD>call VSCodeNotify('redo')<CR>]])
	keymap.set("n", "zz", [[<CMD> call VSCodeNotify('center-editor-window.center')<CR>]])
	keymap.set("n", "<leader>e", [[<CMD>call VSCodeNotify('workbench.explorer.fileView.focus')<CR>]])
	keymap.set("n", "gr", [[<CMD>call VSCodeNotify('editor.action.goToReferences')<CR>]])
	keymap.set("n", "j", "gj", { remap = true })
	keymap.set("n", "k", "gk", { remap = true })
	keymap.set("n", "gy", [[<CMD> call VSCodeNotify('editor.action.goToTypeDefinition')<CR>]])
	-- keymap.set({ "n", "x", "i" }, "<C-n>", function()
	-- vim.g.vscode.with_insert(function()
	--   vim.g.vscode.action("editor.action.addSelectionToNextFindMatch")
	-- end)
	-- end)
end

-- diagnostic
keymap.set("n", "<leader>cb", "<CMD>Telescope diagnostics<CR>", { desc = "Show buffers diagnostics (Telescope)" })

-- keymap.set("n", "<leader>ch", ":LivePreview start<cr>", { desc = "Preview start" })
-- keymap.set("n", "<leader>cH", ":LivePreview close<cr>", { desc = "Preview stop" })

