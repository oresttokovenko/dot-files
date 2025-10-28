vim.lsp.config.ruff = {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    ".git",
  },
  settings = {
    -- Ruff language server settings
  },
}

vim.lsp.enable("ruff")
