return {
  'CopilotC-Nvim/CopilotChat.nvim',
  dependencies = {
    { 'github/copilot.vim' },
    { 'nvim-lua/plenary.nvim' },
  },
  build = 'make tiktoken', -- optional optimization
  config = function()
    require('CopilotChat').setup {
      debug = false,
      window = {
        layout = 'float',
        border = 'rounded',
      },
      prompts = {
        Explain = 'Explain this code',
        Refactor = 'Refactor this code for readability',
        Tests = 'Write unit tests for this code',
        Optimize = 'Optimize this function for performance',
      },
    }

    vim.keymap.set('n', '<leader>cc', ':CopilotChat<CR>', { desc = 'Open Copilot Chat' })
    vim.keymap.set('v', '<leader>ce', ':CopilotChatExplain<CR>', { desc = 'Explain selected code' })
    vim.keymap.set('v', '<leader>cf', ':CopilotChatFix<CR>', { desc = 'Fix selected code' })
  end,
}
