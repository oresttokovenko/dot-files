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
