vim.treesitter.language.register("markdown", "mdx")
vim.treesitter.language.register("json", "jsonl")

require("nvim-treesitter").setup({})

local parsers = {
  "bash",
  "go",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "ruby",
  "tlaplus",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local installed = require("nvim-treesitter.config").get_installed()
local to_install = vim.iter(parsers)
  :filter(function(p) return not vim.tbl_contains(installed, p) end)
  :totable()
if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
