vim.filetype.add({ extension = { qnt = "quint" } })

vim.lsp.config("quint", {
  cmd = { "quint-language-server", "--stdio" },
  filetypes = { "quint" },
  root_markers = { ".git" },
})

vim.lsp.enable("quint")
