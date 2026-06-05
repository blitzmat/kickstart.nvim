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
    vim.lsp.config('typescript-tools', {
      cmd = { 'npx', 'typescript-tools', '--stdio' },
      filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
      root_markers = { 'package.json', 'tsconfig.json', '.git' },
      -- optional extra settings
      settings = {},
    })
    vim.lsp.enable 'typescript-tools'

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

    vim.lsp.config.intelephense = {
      capabilities = capabilities,
      filetypes = { 'php' },
      root_dir = function(fname)
        return require('lspconfig.util').root_pattern(
          'composer.json',
          '.git',
          'artisan' -- Laravel markers
        )(fname) or vim.fn.fnamemodify(fname, ':p:h')
      end,
      settings = {
        intelephense = {
          -- Optional: ignore the licence pop‑up
          licenceKey = '',
          -- You can tune diagnostics, formatting, etc.
          files = {
            maxSize = 2000000, -- 2 MB, adjust as needed
          },
          -- Optional: disable telemetry
          telemetry = { enabled = false },
          -- Optional: explicitly set the environment paths (usually not needed)
          environment = {
            includePaths = '', -- leaving empty uses root
          },
        },
      },
    }
    -- 3. Mason Setup
    require('mason-tool-installer').setup {
      ensure_installed = {
        'stylua',
        'lua-language-server',
        'vue-language-server',
        'eslint-lsp',
        'intelephense',
      },
    }

    require('mason-lspconfig').setup {
      ensure_installed = { 'lua_ls', 'vue_ls', 'intelephense' },
      -- CRITICAL: Disable this to stop Mason from auto-starting ts_ls/vtsls
      automatic_installation = true,
      automatic_enable = false,
    }

    -- 4. Manual Server Activation Logic
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'lua', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue', 'html', 'blade', 'php' },
      callback = function(args)
        local ft_to_servers = {
          lua = { 'lua_ls' },
          typescript = { 'typescript-tools' },
          javascript = { 'typescript-tools' },
          typescriptreact = { 'typescript-tools' },
          javascriptreact = { 'typescript-tools' },
          vue = { 'typescript-tools', 'vue_ls' },
          html = { 'html' },
          blade = { 'html' },
          php = { 'intelephense' },
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
