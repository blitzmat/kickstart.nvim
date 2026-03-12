return {
  'echasnovski/mini.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()

    -- Context-aware commentstring (Vue SFC, etc.)
    require('ts_context_commentstring').setup {
      enable_autocmd = false, -- Recommended when using custom_commentstring
    }

    require('mini.comment').setup {
      mappings = { comment = 'gc', comment_line = 'gcc', comment_visual = 'gc' },
      options = {
        custom_commentstring = function()
          -- Use the internal module's calculation for context-awareness
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    }

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}
