vim.lsp.config.helm_ls = {
  cmd = { "helm_ls", "serve" },
  filetypes = { "helm" },
  root_markers = { "Chart.yaml", ".git" },
}

vim.lsp.enable "helm_ls"
