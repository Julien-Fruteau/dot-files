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
