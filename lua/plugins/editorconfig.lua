return {
  'editorconfig/editorconfig-vim',
  -- Optional: you can add an `event` to load it earlier if needed,
  -- though it often works fine without one or with 'BufReadPre'.
  -- event = "BufReadPre",
  config = function()
    -- No specific configuration needed for editorconfig-vim itself,
    -- it works out of the box once loaded.
  end,
}
