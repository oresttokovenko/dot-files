vim.lsp.config.yamlls = {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      schemas = {
        kubernetes = "*.yaml",
      },
    },
  },
}

vim.lsp.enable "yamlls"
