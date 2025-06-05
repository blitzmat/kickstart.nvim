return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional but recommended
  },
  config = function()
    require('neogit').setup {
      integrations = {
        diffview = true,
      },
    }
  end,
  keys = {
    {
      '<leader>gg',
      function()
        require('neogit').open()
      end,
      desc = 'Open Neogit',
    },
  },
  cmd = 'Neogit',
}
