require("mason").setup({
  ui = {
    border = "rounded",
  },
})

-- Ensure these Mason packages are installed
local ensure_installed = {
  "lua-language-server",
  "basedpyright",
  "ruff",
  "tinymist",
  "html-lsp",
  "css-lsp",
  "typescript-language-server",
  "kotlin-language-server",
  "gopls",
  "sqlls",
  "rust-analyzer",
  "bash-language-server",
  "yaml-language-server",
  "taplo",
  "json-lsp",
  "dockerfile-language-server",
  "terraform-ls",
  "helm-ls",
  "clangd",
  "copilot-language-server",
}

local mason_registry = require("mason-registry")

for _, tool in ipairs(ensure_installed) do
  local p = mason_registry.get_package(tool)
  if not p:is_installed() then p:install() end
end

-- Add nvim-cmp capabilities to LSP servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Load all LSP server configurations
require("lsp.lua_ls")
require("lsp.basedpyright")
require("lsp.ruff")
require("lsp.tinymist")
require("lsp.html")
require("lsp.cssls")
require("lsp.ts_ls")
require("lsp.kotlin_language_server")
require("lsp.gopls")
require("lsp.sqlls")
require("lsp.rust_analyzer")
require("lsp.bashls")
require("lsp.yamlls")
require("lsp.taplo")
require("lsp.jsonls")
require("lsp.dockerls")
require("lsp.terraformls")
require("lsp.helm_ls")
require("lsp.clangd")
require("lsp.copilot")
