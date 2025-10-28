require("mason").setup {
  ui = {
    border = "rounded",
  },
}

require("mason-lspconfig").setup {
  ensure_installed = {
    "lua_ls",
    "basedpyright",
    "ruff",
    "tinymist",
    "html",
    "cssls",
    "ts_ls",
    "kotlin_language_server",
    "gopls",
    "sqlls",
    "rust_analyzer",
    "bashls",
    "yamlls",
    "taplo",
    "jsonls",
    "dockerls",
    "terraformls",
    "helm_ls",
    "clangd",
  },
  automatic_installation = true,
}

-- Add nvim-cmp capabilities to LSP servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
  capabilities = capabilities,
})
