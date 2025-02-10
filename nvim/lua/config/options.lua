local opt = vim.opt -- for conciseness
local g = vim.g -- for conciseness

-- disable autoformat
g.autoformat = false

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = true

-- buffer scroll
opt.scrolloff = 10

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard = "unnamedplus" -- use system clipboard as default register
-- g.clipboard = {
-- 	name = "WslClipboard",
-- 	copy = {
-- 		["+"] = { "clip.exe" },
-- 		["*"] = { "clip.exe" },
-- 	},
-- 	paste = {
-- 		["+"] = {
-- 			"/mnt/c/Windows/System32/WindowsPowerShell/v1.0///powershell.exe",
-- 			"-c",
-- 			'[Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))',
-- 		},
-- 		["*"] = {
-- 			"/mnt/c/Windows/System32/WindowsPowerShell/v1.0///powershell.exe",
-- 			"-c",
-- 			'[Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))',
-- 		},
-- 	},
-- 	cache_enabled = false,
-- }

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Save undo history
opt.undofile = true

-- Set highlight on search
-- opt.hlsearch = false

-- Enable mouse mode
opt.mouse = "a"

-- Enable break indent
opt.breakindent = true
-- decrease update time
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 300
--  completeopt to have a better completion experience
opt.completeopt = "menuone,noselect"

opt.guicursor =
	"n-v-c-sm:block-blinkon500-blinkoff200-blinkwait300,i-ci-ve:ver25-blinkon500-blinkoff200-blinkwait300,r-cr-o:hor20-blinkon500-blinkoff200-blinkwait300"

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
-- vim.g.lazyvim_python_lsp = "basedpyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
-- vim.g.lazyvim_python_ruff = "ruff"

g.root_spec = { "cwd" }
g.python3_host_prog = vim.fn.expand("/home/julien/.local/share/virtualenvs/neovim/bin/python")

