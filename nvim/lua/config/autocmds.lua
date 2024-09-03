-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim

local api = vim.api -- for conciseness

api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json", "jsonc", "yaml", "yml", "markdown", "md", "helm" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
})

-- Turn off paste mode when leaving insert
api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

local hl_group = api.nvim_create_augroup("YankHighlight", {
	clear = true,
})

api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = hl_group,
	pattern = "*",
})

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

