return {
  'yetone/avante.nvim',
  build = vim.fn.has 'win32' ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make',
  event = 'VeryLazy',
  version = false,
  web_search_engine = {
    provider = 'google', -- Requires GOOGLE_SEARCH_API_KEY and GOOGLE_CSE_ID
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    instructions_file = 'avante.md',
    repo_map = {
      ignore_patterns = { '%.git', '%.worktree', '__pycache__', 'node_modules' },
      negate_patterns = {},
    },
    -- Ensure these mentions are enabled so you can trigger them manually
    hints = { enabled = true },
    provider = 'deepseek',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-20250514',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      deepseek = {
        __inherited_from = 'openai',
        endpoint = 'https://api.deepseek.com',
        model = 'deepseek-reasoner',
        -- model = "deepseek-chat",
        api_key_name = 'DEEPSEEK_API_KEY',
        -- timeout = 30000, -- Timeout in milliseconds
        -- extra_request_body = {
        --     temperature = 0.75,
        --     max_tokens = 32768,
        -- },
      },
      moonshot = {
        endpoint = 'https://api.moonshot.ai/v1',
        model = 'kimi-k2-0711-preview',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
      openrouter = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        model = 'qwen/qwen3-coder:free',
        -- model = "deepseek/deepseek-chat-v3-0324:free",
        -- model = "deepseek/deepseek-r1-0528:free",
        api_key_name = 'OPEN_ROUTER_API_KEY',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
      -- 3. Local Ollama Models (Flattened)
      ['local-mistral'] = {
        __inherited_from = 'openai',
        endpoint = 'http://127.0.0.1:11434/v1',
        model = 'mistral:7b-instruct',
        timeout = 30000,
        disable_tools = false,
        is_local = true,
        extra_request_body = {
          options = {
            temperature = 0,
            num_ctx = 16384,
            repeat_penalty = 1.2,
          },
        },
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
