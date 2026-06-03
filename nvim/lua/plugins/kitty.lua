return {
  'mikesmithgh/kitty-scrollback.nvim',
  enabled = true,
  lazy = true,
  cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
  event = { 'User KittyScrollbackLaunch' },
  config = function()
    require('kitty-scrollback').setup({
      -- default config opens the scrollback buffer
      -- 'search' config drops you straight into search mode
      search = {
        callbacks = {
          after_ready = function()
            vim.api.nvim_feedkeys('?', 'n', false)
          end,
        },
      },
    })
  end,
}
