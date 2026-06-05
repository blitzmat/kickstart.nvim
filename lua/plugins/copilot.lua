return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false }, -- avante handles this
      panel = { enabled = false }, -- avante handles this
    }
  end,
}
