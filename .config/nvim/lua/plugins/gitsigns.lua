require("gitsigns").setup({
  signcolumn = true, -- Show signs in the sign column
  numhl = false, -- Don't highlight line numbers
  current_line_blame = false, -- Disable automatic git blame
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
})
