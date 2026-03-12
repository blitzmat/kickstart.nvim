return {
  'echasnovski/mini.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()

    -- 1. Setup context-aware logic
    require('ts_context_commentstring').setup {
      enable_autocmd = false,
    }

    -- 2. Setup mini.comment with context integration
    require('mini.comment').setup {
      mappings = {
        comment = 'gc',
        comment_line = 'gcc',
        comment_visual = 'gc',
        comment_motion = 'gc',
      },
      options = {
        custom_commentstring = function()
          -- 1. Try to get context-aware string (HTML for template, // for script)
          local str = require('ts_context_commentstring').calculate_commentstring()
          if str and str ~= '' then
            return str
          end

          -- 2. If it's a Vue file but TS context failed, manually detect block
          local ft = vim.bo.filetype
          if ft == 'vue' or ft == 'html' then
            -- If we are near an HTML-like tag, use HTML comments
            local line = vim.api.nvim_get_current_line()
            if line:match '<[^>]*>' or ft == 'html' then
              return ''
            end
            return '// %s'
          end

          -- 3. Final fallback
          return vim.bo.commentstring ~= '' and vim.bo.commentstring or '// %s'
        end,
      },
    }

    -- Statusline setup
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}
