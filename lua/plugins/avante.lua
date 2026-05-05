return {
  'yetone/avante.nvim',
  build = vim.fn.has 'win32' ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make',
  event = 'VeryLazy',
  version = false,
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    instructions_file = 'avante.md',
    input = {
      provider = 'dressing', -- or 'snacks' if you have snacks.nvim
    },
    repo_map = {
      ignore_patterns = { '%.git', '%.worktree', '__pycache__', 'node_modules' },
      negate_patterns = {},
    },
    web_search_engine = {
      provider = 'google', -- Requires GOOGLE_SEARCH_API_KEY and GOOGLE_CSE_ID
    },
    system_prompt = function()
      local hub = require('mcphub').get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ''
    end,
    custom_tools = function()
      return { require('mcphub.extensions.avante').mcp_tool() }
    end,
    -- Ensure these mentions are enabled so you can trigger them manually
    hints = { enabled = true },
    hide_reasoning = true,
    provider = 'openrouter-free',
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
        model = 'deepseek-chat', -- supports tools, single response
        api_key_name = 'DEEPSEEK_API_KEY',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
          n = 1, -- only one completion
        },
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
        model = 'openrouter/free',
        -- model = "deepseek/deepseek-chat-v3-0324:free",
        -- model = "deepseek/deepseek-r1-0528:free",
        api_key_name = 'OPEN_ROUTER_API_KEY',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
          n = 1,
        },
        filter_models = function(model_info)
          local tools = model_info.tools or model_info.supported_parameters or {}
          for _, tool in ipairs(tools) do
            if tool == 'edit_file' then
              return true
            end
          end
          return false
        end,
      },
      ['openrouter-free'] = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        model = 'openrouter/free',
        api_key_name = 'OPEN_ROUTER_API_KEY',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
          n = 1, -- request only one completion
        },
        filter_models = function(model_info)
          local tools = model_info.tools or model_info.tool_definitions or {}
          for _, t in ipairs(tools) do
            if t == 'file_edit' then
              return true
            end
          end
          return false
        end,
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
      ['local-qwen'] = {
        __inherited_from = 'openai',
        endpoint = 'http://127.0.0.1:11434/v1',
        model = 'qwen2.5-coder:7b',
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
