vim.lsp.config.tinymist = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { ".git" },
  settings = {
    exportPdf = "onType",
  },
}

vim.lsp.enable "tinymist"
