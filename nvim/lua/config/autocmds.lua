-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim

local api = vim.api -- for conciseness

api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json", "jsonc", "yaml", "yml", "markdown", "md", "helm" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
})

-- -- Turn off paste mode when leaving insert
-- api.nvim_create_autocmd("InsertLeave", {
-- 	pattern = "*",
-- 	command = "set nopaste",
-- })

local hl_group = api.nvim_create_augroup("YankHighlight", {
	clear = true,
})

-- api.nvim_create_autocmd("TextYankPost", {
-- 	callback = function()
-- 		vim.highlight.on_yank()
-- 	end,
-- 	group = hl_group,
-- 	pattern = "*",
-- })

api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function()
		vim.wo.wrap = true
	end,
})

local function KotlinLspJvm(opts)
	local kotlin = require("lspconfig").kotlin_language_server
	kotlin.setup({ settings = { kotlin = { compiler = { jvm = { target = opts.args } } } } })
end

api.nvim_create_user_command("KotlinLspJvm", KotlinLspJvm, { nargs = 1, desc = "Set Kotlin LSP to jvm version" })

local function KotlinLspJvm17()
	local kotlin = require("lspconfig").kotlin_language_server
	kotlin.setup({ settings = { kotlin = { compiler = { jvm = { target = "17" } } } } })
end

api.nvim_create_user_command("KotlinLspJvm17", KotlinLspJvm17, {})

-- local function MagmaInitPython()
--   vim.cmd()
--     vim.cmd[[
--     :MagmaInit python3
--     :MagmaEvaluateArgument a=5
--     ]]
-- end
--
-- api.nvim_create_user_command("MagmaInitPython", MagmaInitPython, { nargs = 0, desc = "Magma Init Python" })

-- api.nvim_create_user_command("FloatTerm", function()
--     -- Calculate dimensions for 70% screen coverage
--     local width = math.floor(vim.o.columns * 0.7)
--     local height = math.floor(vim.o.lines * 0.7)
--
--     -- Calculate starting position to center the window
--     local row = math.floor((vim.o.lines - height) / 2)
--     local col = math.floor((vim.o.columns - width) / 2)
--
--     -- Configure floating window options
--     local opts = {
--         relative = "editor",
--         width = width,
--         height = height,
--         row = row,
--         col = col,
--         border = "rounded",
--     }
--
--     -- Open a new buffer and set it as a terminal
--     local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
--     local win = vim.api.nvim_open_win(buf, true, opts)
--
--     -- Start a terminal in the buffer
--     vim.fn.termopen(vim.o.shell)
--
--     -- Adjust keybindings for the terminal
--     vim.api.nvim_buf_set_keymap(buf, "t", "<Esc><Esc>", [[<C-\><C-n>:q<CR>]], { noremap = true, silent = true })
--     -- vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
--
-- end, {})

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

-- local function create_floating_window(opts)
--   opts = opts or {}
--   local width = opts.width or math.floor(vim.o.columns * 0.8)
--   local height = opts.height or math.floor(vim.o.lines * 0.8)
--
--   -- Calculate the position to center the window
--   local col = math.floor((vim.o.columns - width) / 2)
--   local row = math.floor((vim.o.lines - height) / 2)
--
--   -- Create a buffer
--   local buf = nil
--   if vim.api.nvim_buf_is_valid(opts.buf) then
--     buf = opts.buf
--   else
--     buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
--   end
--
--   -- Define window configuration
--   local win_config = {
--     relative = "editor",
--     width = width,
--     height = height,
--     col = col,
--     row = row,
--     style = "minimal", -- No borders or extra UI elements
--     border = "rounded",
--   }
--
--   -- Create the floating window
--   local win = vim.api.nvim_open_win(buf, true, win_config)
--
--   return { buf = buf, win = win }
-- end

-- local toggle_terminal = function()
--   if not vim.api.nvim_win_is_valid(state.floating.win) then
--     state.floating = create_floating_window { buf = state.floating.buf }
--     if vim.bo[state.floating.buf].buftype ~= "terminal" then
--       vim.cmd.terminal()
--     end
--   else
--     vim.api.nvim_win_hide(state.floating.win)
--   end
-- end

-- Example usage:
-- Create a floating window with default dimensions
-- vim.api.nvim_create_user_command("FloatTerm", toggle_terminal, {})

