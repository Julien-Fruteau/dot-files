return {
	"karb94/neoscroll.nvim",
	config = function()
    local neoscroll = require('neoscroll')
    local keymap = {
      ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250 }) end;
      ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end;
      ["<C-y>"] = function() neoscroll.scroll(-0.01, { move_cursor=true; duration = 10 }) end;
      ["<C-e>"] = function() neoscroll.scroll(0.01, { move_cursor=true; duration = 10 }) end;
      ["zt"]    = function() neoscroll.zt({ half_win_duration = 250 }) end;
      ["zz"]    = function() neoscroll.zz({ half_win_duration = 250 }) end;
      ["zb"]    = function() neoscroll.zb({ half_win_duration = 250 }) end;
    }
    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
		-- require("neoscroll").setup({})
		-- local t = {}
		-- -- Syntax: t[keys] = {function, {function arguments}}
		-- t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "250" } }
		-- t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "250" } }
		-- -- t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
		-- -- t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
		--   t['<C-y>'] = {'scroll', {'-0.010', 'true', '10', nil}}
		--   t['<C-e>'] = {'scroll', { '0.010', 'true', '10', nil}}
		-- -- t["<C-y>"] = { "scroll", { "-0.10", "true", "100" } }
		-- -- t["<C-e>"] = { "scroll", { "0.10", "true", "100" } }
		-- t["zt"] = { "zt", { "250" } }
		-- t["zz"] = { "zz", { "250" } }
		-- t["zb"] = { "zb", { "250" } }
		--
		-- require("neoscroll.config").set_mappings(t)
	end,
}
