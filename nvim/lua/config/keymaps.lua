-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }
---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
-- keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jk" })

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
keymap.set("n", "ss", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
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
keymap.set("n", "<M-z>", ":b#<CR>", { desc = "Focus to previous active buffer" }) --  Focus to previous active buffer

keymap.set("n", "<leader>fs", "<CMD>w<CR>", { desc = "File save" }) -- file save

-- neo-tree
keymap.set("n", "<leader>e", ":Neotree focus<cr>", { desc = "Explorer focus on File Explorer" })
-- keymap.set("n", "<leader>E", ":Neotree toggle<cr>", { desc = "Explorer toggle File Explorer" })

-- git-worktree
keymap.set(
	"n",
	"<leader>gr",
	"<CMD>lua require('telescope').extensions.git_worktree.git_worktree()<CR>",
	{ desc = "Switch between worktree" }
)
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

-- maximiser 
keymap.set("n", "<leader>wm", "<CMD>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })

-- dapui
keymap.set("n", "<leader>dd", "<CMD>DapShowLog<CR>", { desc = "Dap show logs"})
