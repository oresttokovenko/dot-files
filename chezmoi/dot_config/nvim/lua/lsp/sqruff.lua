-- Lints and formats SQL via sqruff (quarylabs/sqruff).
-- Dialect and rules come from the project's `.sqruff` file (see wiring docs / usage/configuration).
-- Neovim recipe: https://github.com/nvim-lspconfig/blob/master/lsp/sqruff.lua -- cmd = { "sqruff", "lsp" }
vim.lsp.enable("sqruff")
