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

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- 1. Setup typescript-tools (Disable this if you want to use vtsls/ts_ls instead)
    require('typescript-tools').setup {
      capabilities = capabilities,
      settings = {
        -- This helps prevent typescript-tools from fighting with Volar
        expose_as_code_action = 'all',
        tsserver_plugins = {
          '@vue/typescript-plugin',
        },
      },
    }

    -- 2. Define Server Configurations
    vim.lsp.config.lua_ls = {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = { 'vim' } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    }

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
        vue = { hybridMode = true },
      },
      on_new_config = function(new_config, new_root_dir)
        if vim.env.NVIM_TS == 'typescript-tools' then
          new_config.init_options.typescript.tsdk = nil
        end
      end,
    }

    -- 3. Mason Setup
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
      -- CRITICAL: Disable this to stop Mason from auto-starting ts_ls/vtsls
      automatic_installation = true,
      automatic_enable = false,
    }

    -- 4. Manual Server Activation Logic
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'lua', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue', 'html', 'blade' },
      callback = function(args)
        local ft_to_servers = {
          lua = { 'lua_ls' },
          typescript = { 'typescript-tools' },
          javascript = { 'typescript-tools' },
          typescriptreact = { 'typescript-tools' },
          javascriptreact = { 'typescript-tools' },
          -- FIX: Make sure BOTH are listed here clearly
          vue = { 'typescript-tools', 'vue_ls' },
          html = { 'html' },
          blade = { 'html' },
        }

        local servers = ft_to_servers[args.match]
        if not servers then
          return
        end

        for _, name in ipairs(servers) do
          vim.lsp.enable(name)
          -- Force start if not already running
          if #vim.lsp.get_clients { name = name, bufnr = args.buf } == 0 then
            vim.cmd('LspStart ' .. name)
          end
        end
      end,
    })
  end,
}
