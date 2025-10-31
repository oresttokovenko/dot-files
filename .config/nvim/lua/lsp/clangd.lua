vim.lsp.config.clangd = {
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
}

vim.lsp.enable("clangd")
