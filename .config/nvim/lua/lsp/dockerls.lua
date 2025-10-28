vim.lsp.config.dockerls = {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_markers = { "Dockerfile", ".git" },
}

vim.lsp.enable "dockerls"
