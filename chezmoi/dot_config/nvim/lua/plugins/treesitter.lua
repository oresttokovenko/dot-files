-- Use the markdown parser for mdx files
vim.treesitter.language.register("markdown", "mdx")
-- Use the json parser for jsonl files
vim.treesitter.language.register("json", "jsonl")

require("nvim-treesitter.configs").setup({
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
  modules = {},
  ignore_install = {},
  sync_install = false,
  -- If parser isn't already installed, get it
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})
