return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'folke/lazydev.nvim',
    'saghen/blink.cmp',
    'pmizio/typescript-tools.nvim',
  },
  config = function()
    -- Your existing LspAttach autocommand (keep this as-is)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
      callback = function(event)
        -- ... your existing keymaps code ...
      end,
    })

    -- Modern diagnostic configuration (keep as-is)
    vim.diagnostic.config {
      -- ... your existing diagnostic config ...
    }

    -- Get capabilities from blink.cmp
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Setup typescript-tools
    require('typescript-tools').setup {
      capabilities = capabilities,
    }

    -- Lua server setup
    vim.lsp.config.lua_ls = {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = { 'vim' } },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
          completion = { callSnippet = 'Replace' },
        },
      },
    }

    -- Vue LSP configuration - FIXED VERSION
    vim.lsp.config.vue_ls = {
      capabilities = capabilities,
      filetypes = { 'vue' },
      init_options = {
        typescript = {
          tsdk = (function()
            local root_dir = require('lspconfig.util').root_pattern('package.json', 'node_modules')(vim.fn.getcwd())
            return root_dir and (root_dir .. '/node_modules/typescript/lib') or ''
          end)(),
        },
        vue = {
          hybridMode = true,
        },
      },
    }

    -- HTML configuration
    vim.lsp.config('html', {
      filetypes = { 'html', 'blade' },
      capabilities = capabilities,
      init_options = {
        embeddedLanguages = {
          css = true,
          javascript = true,
        },
      },
    })
    vim.lsp.enable 'html'

    -- GDScript configuration
    vim.lsp.config.gdscript = {
      cmd = { '/home/blitzmat/godot', '--headless', '--editor', '--lsp' },
      filetypes = { 'gd', 'gdscript' },
      root_dir = require('lspconfig.util').root_pattern 'project.godot',
      capabilities = capabilities,
    }

    -- Mason setup
    require('mason-tool-installer').setup {
      ensure_installed = {
        'stylua',
        'lua-language-server',
        'vue-language-server',
        'eslint-lsp',
      },
    }

    require('mason-lspconfig').setup {
      ensure_installed = { 'lua_ls', 'vue_ls' },
      automatic_installation = true,
      automatic_enable = true,
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'lua', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
      callback = function(args)
        local ft_to_servers = {
          lua = { 'lua_ls' },
          typescript = { 'typescript-tools' },
          javascript = { 'typescript-tools' },
          typescriptreact = { 'typescript-tools' },
          javascriptreact = { 'typescript-tools' },
          vue = { 'vue_ls', 'typescript-tools' }, -- important
        }

        local servers = ft_to_servers[args.match]
        if not servers then
          return
        end

        vim.schedule(function()
          for _, name in ipairs(servers) do
            vim.lsp.enable(name)
            if #vim.lsp.get_clients { bufnr = args.buf, name = name } == 0 then
              vim.cmd('LspStart ' .. name)
            end
          end
        end)
      end,
    })
  end,
}
