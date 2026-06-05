return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false,
  build = 'make',

  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
    'zbirenbaum/copilot.lua',
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
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

  opts = {
    -- -------------------------------------------------------------------------
    -- Default Provider
    -- -------------------------------------------------------------------------
    provider = 'copilot',
    auto_suggestions_provider = 'copilot',
    hide_reasoning = true,

    -- -------------------------------------------------------------------------
    -- Provider Configuration
    -- -------------------------------------------------------------------------
    providers = {
      copilot = {
        endpoint = 'https://api.githubcopilot.com',
        model = 'gpt-4o-2024-11-20',
        proxy = nil,
        allow_insecure = false,
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 8096,
        },
      },
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-5',
        extra_request_body = {
          temperature = 0,
          max_tokens = 8096,
        },
      },
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-4o',
        extra_request_body = {
          temperature = 0,
          max_tokens = 8096,
        },
      },
      -- Integrated Gemini Provider for heavy context design files
      gemini = {
        __inherited_from = 'openai',
        endpoint = 'https://generativelanguage.googleapis.com/v1beta/openai',
        model = 'gemini-2.5-pro',
        api_key_name = 'GEMINI_API_KEY',
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 8096,
        },
      },
      free_tool_model = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        model = 'openrouter/free',
        api_key_name = 'OPENROUTER_API_KEY',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.2,
          max_tokens = 2048,
          stop = { '\n\n', '```' },
        },
        filter_models = function(model_info)
          local tools = model_info.supported_parameters or {}
          for _, param in ipairs(tools) do
            if param == 'tools' or param == 'tool_choice' then
              return true
            end
          end
          return false
        end,
      },
      -- Local Ollama Entry
      ollama = {
        __inherited_from = 'openai',
        endpoint = 'http://localhost:11434/v1',
        model = 'qwen3.5:9b', -- Acts as default fallback
        api_key_name = '',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.7,
          max_tokens = 2048,
          stop = { '\n\n', '<|im_end|>', '<|endoftext|>', '```' },
          repeat_penalty = 1.1,
          stream = false,
        },
      },
      -- Cloud/Remote Ollama Entry
      ollama_cloud = {
        __inherited_from = 'openai',
        endpoint = 'https://your-cloud-ollama-domain.com/v1', -- Change this to your remote/cloud endpoint
        model = 'qwen3.5:14b',
        api_key_name = 'OLLAMA_CLOUD_API_KEY', -- Keep if secured via reverse proxy auth
        timeout = 45000,
        extra_request_body = {
          temperature = 0.5,
          max_tokens = 4096,
          stream = false,
        },
      },
      ollama_autocomplete = {
        __inherited_from = 'openai',
        endpoint = 'http://localhost:11434/v1',
        model = 'qwen2.5-coder:1.5b',
        api_key_name = '',
        timeout = 30000,
        disable_tools = true,
        extra_request_body = {
          temperature = 0,
          max_tokens = 256,
        },
      },
    },

    -- -------------------------------------------------------------------------
    -- Global System Prompt (agent-skills coding standards)
    -- -------------------------------------------------------------------------
    system_prompt = [[
You are an expert software engineer and pair programmer. Follow these principles:

## Testing
- Write tests before code (TDD)
- For bugs: write a failing test first, then fix (Prove-It pattern)
- Test hierarchy: unit > integration > e2e (use the lowest level that captures the behavior)
- Run `npm test` or structural linter checks after every change

## Code Quality
- Review across five axes: correctness, readability, architecture, security, performance
- Every PR must pass: lint, type check, tests, build
- No secrets in code or version control

## Implementation
- Build in small, verifiable increments
- Each increment: implement → test → verify
- Never mix formatting changes with behavior changes

## Boundaries
- Always: Run tests before handing off changes, validate user input
- Ask first: Database schema changes, new dependencies
- Never: Commit anything to git (no `git commit`, no `git add` followed by commit, no automated commits under any circumstances), commit secrets, remove failing tests, skip verification

## Git Policy
- **Do not run `git commit`, `git push`, or any command that creates a commit.**
- Leave all staging and commit decisions to the human user.
- If a workflow seems to require a commit, stop and ask the user to perform it themselves.

## Communication
- Be specific and actionable in feedback
- Explain the "why" behind suggestions
- Flag potential issues before they become problems
]],

    -- -------------------------------------------------------------------------
    -- Behavior Settings
    -- -------------------------------------------------------------------------
    behaviour = {
      allow_access_to_git_ignored_files = true,
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
      minimize_diff = true,
    },

    -- -------------------------------------------------------------------------
    -- UI Settings
    -- -------------------------------------------------------------------------
    windows = {
      position = 'right',
      wrap = true,
      width = 40,
      sidebar_header = {
        enabled = true,
        align = 'center',
        rounded = true,
      },
      input = {
        prefix = '> ',
        height = 8,
      },
      edit = {
        border = 'rounded',
        start_insert = true,
      },
      ask = {
        floating = false,
        start_insert = true,
        border = 'rounded',
        focus_on_apply = 'ours',
      },
    },

    -- -------------------------------------------------------------------------
    -- Highlights
    -- -------------------------------------------------------------------------
    highlights = {
      diff = {
        current = 'DiffText',
        incoming = 'DiffAdd',
      },
    },

    -- -------------------------------------------------------------------------
    -- Diff Settings
    -- -------------------------------------------------------------------------
    diff = {
      autojump = true,
      list_opener = 'copen',
      override_timeoutlen = 500,
    },

    -- -------------------------------------------------------------------------
    -- Hints
    -- -------------------------------------------------------------------------
    hints = {
      enabled = true,
    },

    -- -------------------------------------------------------------------------
    -- Mappings
    -- -------------------------------------------------------------------------
    mappings = {
      diff = {
        ours = 'co',
        theirs = 'ct',
        all_theirs = 'ca',
        both = 'cb',
        cursor = 'cc',
        next = ']x',
        prev = '[x',
      },
      suggestion = {
        accept = '<M-l>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
      jump = {
        next = ']]',
        prev = '[[',
      },
      submit = {
        normal = '<CR>',
        insert = '<C-s>',
      },
      cancel = {
        normal = { '<C-c>', 'q' },
        insert = { '<C-c>' },
      },
      sidebar = {
        apply_all = 'A',
        apply_cursor = 'a',
        switch_windows = '<Tab>',
        reverse_switch_windows = '<S-Tab>',
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- Custom Keys / Agent Personas & Skills
  -- ---------------------------------------------------------------------------
  keys = {
    -- Core Avante commands
    {
      '<leader>aa',
      function()
        require('avante.api').ask()
      end,
      desc = 'Avante: Ask',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ae',
      function()
        require('avante.api').edit()
      end,
      desc = 'Avante: Edit',
      mode = { 'v' },
    },
    {
      '<leader>ar',
      function()
        require('avante.api').refresh()
      end,
      desc = 'Avante: Refresh',
    },
    {
      '<leader>at',
      function()
        require('avante.api').toggle()
      end,
      desc = 'Avante: Toggle',
    },

    -- [All your default custom keys remain completely intact]
    {
      '<leader>acr',
      function()
        require('avante.api').ask {
          question = [[
Act as an expert **code reviewer**. Review the selected code across five axes:
1. **Correctness** — Logic errors, edge cases, off-by-one errors
2. **Readability** — Naming, structure, clarity, comments
3. **Architecture** — Design patterns, separation of concerns, SOLID principles
4. **Security** — Input validation, injection risks, exposed secrets, auth issues
5. **Performance** — Algorithmic complexity, unnecessary re-renders, N+1 queries

For each issue found: State the axis, describe the problem, and provide a concrete fix.
          ]],
        }
      end,
      desc = 'Avante: [Agent] Code Reviewer',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ate',
      function()
        require('avante.api').ask {
          question = [[
Act as an expert **test engineer**. Analyze the selected code and evaluate coverage gaps, test quality, TDD opportunities, and concrete suggestions.
Use the lowest test level (unit > integration > e2e) that captures the behavior.
          ]],
        }
      end,
      desc = 'Avante: [Agent] Test Engineer',
      mode = { 'n', 'v' },
    },
    {
      '<leader>asa',
      function()
        require('avante.api').ask {
          question = [[
Act as an expert **security auditor**. Analyze the selected code for Injection risks, Auth/Authorizations issues, Secrets/Sensitive Data handling, Input Validation patterns, and OWASP Top 10 vulnerabilities.
          ]],
        }
      end,
      desc = 'Avante: [Agent] Security Auditor',
      mode = { 'n', 'v' },
    },
    {
      '<leader>aac',
      function()
        require('avante.api').ask {
          question = [[
Act as a **software architect**. Review the selected code and evaluate design patterns, separation of concerns, SOLID principles, scalability, and technical debt.
          ]],
        }
      end,
      desc = 'Avante: [Agent] Architect',
      mode = { 'n', 'v' },
    },
    {
      '<leader>awp',
      function()
        require('avante.api').ask {
          question = [[
Act as an expert **WordPress Layout & Block Architect**. Your goal is to map design layout requirements into native WordPress Block Core architecture.

Guidelines:
1. Prioritize native Gutenberg blocks (`core/group`, `core/columns`, `core/stack`) wrapped cleanly inside block pattern registration schemas (`register_block_pattern`).
2. Utilize global configurations defined within `theme.json` for custom spacing, typography scales, and structural color schemes instead of outputting inline CSS styles.
3. Keep layout loops clean, isolated, and semantically optimized for the Site Editor experience.
          ]],
        }
      end,
      desc = 'Avante: [Agent] WordPress Architect',
      mode = { 'n', 'v' },
    },
    {
      '<leader>amcp',
      function()
        require('avante.api').ask {
          question = [[
Act as an automation operator leveraging **mcphub.nvim** tools. You have full systemic capability via configured Model Context Protocol servers to parse, test, and run active runtime utilities.

Guidelines:
1. Coordinate with local shell tools or WP-CLI helpers to run asset compilations, error log scans, or live environment cache purges.
2. If compilation outputs an exception or asset error flags are raised, parse the log syntax directly, correct the targeted asset file, and trigger the compilation checkpoint again.
          ]],
        }
      end,
      desc = 'Avante: [Agent] MCP Automation Worker',
      mode = { 'n', 'v' },
    },
    {
      '<leader>atdd',
      function()
        require('avante.api').ask {
          question = [[
Apply **Test-Driven Development (TDD)**:
1. Read the selected code or description
2. Write a **failing test** that captures the expected behavior
3. Show the minimal implementation to make it pass
4. Suggest refactoring once green
Follow: Red → Green → Refactor
          ]],
        }
      end,
      desc = 'Avante: [Skill] TDD - Write Failing Test',
      mode = { 'n', 'v' },
    },
    {
      '<leader>api',
      function()
        require('avante.api').ask {
          question = [[
Apply the **Prove-It pattern** for this bug:
1. Write a **failing test** that reproduces the bug exactly
2. Confirm the test fails for the right reason
3. Write the **minimal fix** to make the test pass
4. Ensure no other tests break
Show each step explicitly. Do not fix the bug before writing the test.
          ]],
        }
      end,
      desc = 'Avante: [Skill] Prove-It Bug Fix',
      mode = { 'n', 'v' },
    },
    {
      '<leader>aib',
      function()
        require('avante.api').ask {
          question = [[
Break this task into **small, verifiable increments**:
For each increment:
1. **What** — Describe the change
2. **Implement** — The code change
3. **Test** — How to verify it works
Rules: Independently deployable, don't mix formatting with behavior changes, test between steps.
          ]],
        }
      end,
      desc = 'Avante: [Skill] Incremental Build Plan',
      mode = { 'n', 'v' },
    },
    {
      '<leader>als',
      function()
        local skill_dir = vim.fn.getcwd() .. '/.avante/skills'
        local files = vim.fn.glob(skill_dir .. '/*.md', false, true)

        if #files == 0 then
          vim.notify('No skill files found in .avante/skills/', vim.log.levels.WARN)
          return
        end

        vim.ui.select(files, {
          prompt = 'Select a skill to load:',
          format_item = function(item)
            return vim.fn.fnamemodify(item, ':t')
          end,
        }, function(choice)
          if choice then
            local content = table.concat(vim.fn.readfile(choice), '\n')
            require('avante.api').ask {
              question = 'Apply the following skill to my current work:\n\n' .. content,
            }
          end
        end)
      end,
      desc = 'Avante: Load Skill File',
    },

    -- -------------------------------------------------------------------------
    -- UPDATED: Dynamic Provider & Dynamic Model Switcher
    -- -------------------------------------------------------------------------
    {
      '<leader>asp',
      function()
        local providers = { 'copilot', 'claude', 'openai', 'gemini', 'ollama (Local)', 'ollama (Cloud)' }

        vim.ui.select(providers, {
          prompt = 'Select AI Provider:',
        }, function(choice)
          if not choice then
            return
          end

          -- Helper function to fetch models from an Ollama instance endpoint via curl
          local function select_ollama_model(provider_key, endpoint_url)
            -- Queries Ollama's native API endpoint tags
            local cmd = string.format('curl -s %s/api/tags', endpoint_url:gsub('/v1$', ''))
            local output = vim.fn.system(cmd)
            local success, data = pcall(vim.json.decode, output)

            local models = {}
            if success and data and data.models then
              for _, m in ipairs(data.models) do
                table.insert(models, m.name)
              end
            else
              -- Fallback directly to native terminal execution line if curl fallback fails
              if provider_key == 'ollama' then
                local local_list = vim.fn.systemlist 'ollama list'
                for i = 2, #local_list do
                  local name = local_list[i]:match '^%S+'
                  if name then
                    table.insert(models, name)
                  end
                end
              end
            end

            if #models == 0 then
              vim.notify('No active Ollama models discovered on this endpoint.', vim.log.levels.WARN)
              return
            end

            -- Sub-picker displaying discovered models
            vim.ui.select(models, {
              prompt = string.format('Select Model for %s:', provider_key),
            }, function(model_choice)
              if model_choice then
                require('avante').setup {
                  provider = provider_key,
                  providers = {
                    [provider_key] = {
                      model = model_choice,
                    },
                  },
                }
                vim.notify(string.format('Avante: Switched to %s (%s)', provider_key, model_choice), vim.log.levels.INFO)
              end
            end)
          end

          -- Route selections based on choice
          if choice == 'ollama (Local)' then
            select_ollama_model('ollama', 'http://localhost:11434')
          elseif choice == 'ollama (Cloud)' then
            -- Pulls endpoint directly out of the config setup down below
            local cloud_endpoint = require('avante.config').providers.ollama_cloud.endpoint
            select_ollama_model('ollama_cloud', cloud_endpoint)
          else
            -- Handling for normal cloud setups
            require('avante').setup { provider = choice }
            vim.notify('Avante: Switched to ' .. choice, vim.log.levels.INFO)
          end
        end)
      end,
      desc = 'Avante: Switch Provider / Ollama Model',
    },
    {
      '<leader>ats',
      function()
        local new_val = not require('avante.config').behaviour.auto_suggestions
        require('avante').setup { behaviour = { auto_suggestions = new_val } }
        vim.notify('Avante auto-suggestions: ' .. tostring(new_val), vim.log.levels.INFO)
      end,
      desc = 'Avante: Toggle Auto‑Suggestions',
      mode = { 'n' },
    },
  },

  -- ---------------------------------------------------------------------------
  -- Post-setup config
  -- ---------------------------------------------------------------------------
  config = function(_, opts)
    require('avante').setup(opts)

    -- Notify which rules file is active for this project
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        local cwd = vim.fn.getcwd()
        local rules_files = {
          cwd .. '/.cursorrules',
          cwd .. '/AGENTS.md',
          cwd .. '/.avante/instructions.md',
        }
        for _, file in ipairs(rules_files) do
          if vim.fn.filereadable(file) == 1 then
            vim.notify('Avante: Loaded project rules from ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.INFO)
            break
          end
        end
      end,
    })
  end,
}
