local g = vim.g -- for conciseness

-- disable autoformat
g.autoformat = true

-- cliptboard
-- nb: wsl or linux just install xsel, with apt package manager 

--
-- wsl clipboard
-- local in_wsl = os.getenv("WSL_DISTRO_NAME") ~= nil
-- if in_wsl then
-- 	g.clipboard = {
-- 		name = "WslClipboard",
-- 		copy = {
-- 			["+"] = { "clip.exe" },
-- 			["*"] = { "clip.exe" },
-- 		},
-- 		paste = {
-- 			["+"] = { "nvim_paste" },
-- 			["*"] = { "nvim_paste" },
-- 		},
-- 		cache_enabled = true,
-- 	}
-- end

-- local in_linux = vim.loop.os_uname().sysname ~= "Linux"
-- if in_linux then
--   g.clipboard = {
-- 		name = "LinuxClipboard",
-- 		copy = {
-- 			["+"] = { "xsel" },
-- 			["*"] = { "xsel" },
-- 		},
-- 		paste = {
-- 			["+"] = { "xsel" },
-- 			["*"] = { "xsel" },
-- 		},
-- 		cache_enabled = true,
-- }
-- end
