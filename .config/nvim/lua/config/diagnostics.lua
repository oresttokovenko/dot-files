vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    virt_text_pos = "eol",
  },
  signs = true,  -- Show diagnostic signs in sign column
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    source = "if_many",
    border = "rounded",
  },
})
