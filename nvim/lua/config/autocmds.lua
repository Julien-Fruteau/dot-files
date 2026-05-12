-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim

local api = vim.api -- for conciseness

api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json", "jsonc", "yaml", "yml", "markdown", "md", "helm" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
})

api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function()
		vim.wo.wrap = true
	end,
})

