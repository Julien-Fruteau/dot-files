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
-- keymap.set("n", "<leader>ls", "<CMD>Lazy show<CR>", { desc = "Lazy Show" })
-- keymap.set("n", "<leader>lS", "<CMD>Lazy sync<CR>", { desc = "Lazy Sync" })

-- window management
-- keymap.set("n", "sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
-- keymap.set("n", "ss", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally

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
	local buf = vim.api.nvim_get_current_buf()
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

-- magma (python jupyter)
-- Required Python packages:
-- pynvim (for the Remote Plugin API)
-- jupyter_client (for interacting with Jupyter)
-- ueberzug (for displaying images. Not available on MacOS, but see #15 for alternatives)
-- Pillow (also for displaying images, should be installed with ueberzug)
-- cairosvg (for displaying SVG images)
-- pnglatex (for displaying TeX formulas)
-- plotly and kaleido (for displaying Plotly figures)
-- pyperclip if you want to use magma_copy_output

-- keymap.set("n", "<leader>mo", ":MagmaEvaluateOperator<CR>", { desc = "Magma (jupy) eval operator" })
-- keymap.set("n", "<leader>mr", ":MagmaEvaluateLine<CR>", { desc = "Magma (jupy) eval line" })
-- keymap.set("n", "<leader>mu", ":<C-u>MagmaEvaluateVisual<CR>", { desc = "Magma (jupy) eval visual" })
-- keymap.set("n", "<leader>mc", ":MagmaReevaluateCell<CR>", { desc = "Magma (jupy) reeval cell" })
-- keymap.set("n", "<leader>md", ":MagmaDelete<CR>", { desc = "Magma (jupy) delete" })
-- keymap.set("n", "<leader>mo", ":MagmaShowOutput<CR>", { desc = "Magma (jupy) show output" })

keymap.set("n", "<leader>ch", ":LivePreview start<cr>", { desc = "Preview start" })
keymap.set("n", "<leader>cH", ":LivePreview close<cr>", { desc = "Preview stop" })

-- keymap.set("n", "<Leader>t_", ":lua open_floating_terminal()<CR>", { noremap = true, silent = true })
-- Clear the terminal with Ctrl+L in terminal mode
-- vim.keymap.set('t', '<C-l>', '<Cmd>clear<CR>', { remap = true, silent = true })

-- molten jupyter kernel
keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize the plugin" })
keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "run operator selection" })
keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
keymap.set("n", "<leader>mc", ":MoltenReevaluateCell<CR>", { silent = true, desc = "re-evaluate cell" })
keymap.set(
	"v",
	"<leader>mv",
	":<C-u>MoltenEvaluateVisual<CR>gv",
	{ silent = true, desc = "evaluate visual selection" }
)
keymap.set("n", "<leader>md", ":MoltenDeinit<CR>", { silent = true, desc = "deinit" })
