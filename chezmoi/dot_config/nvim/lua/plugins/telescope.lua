require("telescope").setup({
  defaults = {
    prompt_prefix = "   ",
    -- selection_caret and entry_prefix must have the same width to prevent entries from shifting when navigating
    selection_caret = "  ",
    entry_prefix = "  ",
    path_display = { "smart" },
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
      },
      width = 0.87,
      height = 0.80,
    },
  },
})

-- fzf's query syntax: 'exact, ^prefix, suffix$, !inverse, | OR, and ^x$ for equality.
-- Wrapped because a missing compiled library must not break every picker.
local ok, err = pcall(function()
  require("telescope").load_extension("fzf")
end)
if not ok then
  vim.notify("telescope fzf extension unavailable: " .. tostring(err), vim.log.levels.WARN)
end
