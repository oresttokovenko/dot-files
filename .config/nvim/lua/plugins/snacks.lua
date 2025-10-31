local snacks = require("snacks")

snacks.setup({
  indent = {
    indent = { char = "▏" },
    scope = { char = "▏" },
    filter = function(bufnr)
      return vim.bo[bufnr].buftype == ""
        and vim.api.nvim_buf_line_count(bufnr) < 10000
        and vim.g.snacks_indent ~= false
        and vim.b[bufnr].snacks_indent ~= false
    end,
    animate = { enabled = false },
  },
  scope = {
    filter = function(bufnr) return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_line_count(bufnr) < 10000 end,
  },
})

-- Toggle indent guides keymap
vim.keymap.set("n", "<leader>ui", function() snacks.toggle.indent():toggle() end, { desc = "Toggle indent guides" })
