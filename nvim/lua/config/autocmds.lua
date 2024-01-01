-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim

local api = vim.api -- for conciseness

api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json", "jsonc", "yaml", "yml", "markdown", "md", "helm" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
})

-- vim.cmd([[ autocmd FileType helm setlocal commentstring=#\ %s ]])

-- - vim.api.nvim_create_autocmd("FileType", {
-- 	group = vim.api.nvim_create_augroup("CommentString", { clear = false }),
-- 	pattern = { "helm" },
-- 	callback = function()
-- 		vim.bo.commentstring = "# %s"
-- 	end,
-- })

-- api.nvim_create_autocmd({ "FileType" }, {
-- 	pattern = { "helm", "yaml", "yml" },
-- 	command = "setlocal commentstring=#\\ %s",
-- 	-- command = "echo 'filetype %s'",
-- 	-- callback = function()
-- 	-- 	vim.bo.commentstring = "# %s"
-- 	-- end,
-- 	-- desc = "Change commentstring for helm files",
-- })

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
