-- Use the markdown parser for mdx files
vim.treesitter.language.register("markdown", "mdx")
-- Use the json parser for jsonl files
vim.treesitter.language.register("json", "jsonl")

-- On the `main` branch, nvim-treesitter only handles parser installation.
-- Highlighting, indentation, and folding must be enabled manually.
require("nvim-treesitter").setup({
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "python",
    "javascript",
    "typescript",
    "json",
    "yaml",
    "toml",
    "markdown",
    "markdown_inline",
    "bash",
    "regex",
    "go",
    "java",
    "tlaplus",
  },
  auto_install = true,
})

-- Enable treesitter highlighting and indentation for all filetypes
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
