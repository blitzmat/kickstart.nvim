local function get_windows_host_ip()
  -- This command finds the default gateway (your Windows Host) inside WSL
  local cmd = "ip route | grep default | awk '{print $3}'"
  local handle = io.popen(cmd)
  local result = handle:read '*a'
  handle:close()
  return result:gsub('%s+', '') -- Remove whitespace/newlines
end

local win_ip = get_windows_host_ip()

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
    provider = 'gemini',
    providers = {
      gemini = {
        -- Updated to Gemini 3.1 Pro endpoint
        endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent',
        model = 'gemini-3.1-flash-lite-preview',
        timeout = 30000,
        temperature = 0,
        max_tokens = 4096,
        max_iterations = 1,
        parse_curl_args = function(opts, code_opts)
          return {
            url = opts.endpoint .. '?key=' .. os.getenv 'GEMINI_API_KEY',
            headers = { ['Content-Type'] = 'application/json' },
            body = {
              contents = {
                { role = 'user', parts = { { text = code_opts.instructions or code_opts.prompt or 'hi' } } },
              },
              generationConfig = {
                temperature = 0,
                -- CRITICAL: Disable the new March 2026 'Thinking' to stop the loop
                thinkingConfig = { includeThoughts = false },
                maxOutputTokens = opts.max_tokens,
              },
            },
          }
        end,

        parse_response_data = function(data_stream, event_state, opts)
          if event_state == 'complete' then
            return
          end
          local ok, json = pcall(vim.json.decode, data_stream)

          -- Only process if we have a valid text part
          if ok and json.candidates and json.candidates[1].content.parts then
            local parts = json.candidates[1].content.parts
            for _, part in ipairs(parts) do
              -- Skip anything tagged as 'thought' or 'call'
              if part.text and not part.thought and not part.functionCall then
                opts.on_chunk(part.text)
                return -- Stop parsing after first valid text to prevent echoes
              end
            end
          end
        end,
      },

      ['OR: Qwen3 Coder'] = {
        __inherited_from = 'openai', -- Inherit directly from the built-in 'openai' engine
        endpoint = 'https://openrouter.ai/api/v1',
        model = 'qwen/qwen3-coder:free',
        api_key_name = 'OPENROUTER_API_KEY',
        timeout = 30000,
      },
      ['OR: Llama 3.3'] = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        model = 'meta-llama/llama-3.3-70b-instruct:free',
        api_key_name = 'OPENROUTER_API_KEY',
        timeout = 30000,
      },

      -- 3. Local Ollama Models (Flattened)
      ['local-deepseek'] = {
        __inherited_from = 'openai',
        endpoint = 'http://127.0.0.1:11434/v1',
        model = 'deepseek-coder-v2:16b',
        timeout = 30000,
        -- This is the key line to stop the "does not support tools" error
        disable_tools = true,
        extra_request_body = {
          options = { temperature = 0, num_ctx = 8192 },
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
    'nvim-telescope/telescope.nvim',
    'hrsh7th/nvim-cmp',
    'ibhagwan/fzf-lua',
    'stevearc/dressing.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
