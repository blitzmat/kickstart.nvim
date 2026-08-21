return {
  'zbirenbaum/copilot.lua',
  lazy = false,
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false }, -- avante handles this
      panel = { enabled = false }, -- avante handles this
    }
  end,
}
