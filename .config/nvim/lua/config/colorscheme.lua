require("github-theme").setup {
  groups = {
    all = {
      -- Colors from: https://github.com/projekt0n/github-nvim-theme/blob/main/lua/github-theme/palette/primitives/dark_dimmed.lua
      -- Using a medium-dark grey cursor so light text is visible
      -- bg: #636e7b - medium grey that provides good contrast with light text
      Cursor = { bg = "#636e7b" },
      lCursor = { bg = "#636e7b" },
      TermCursor = { bg = "#636e7b" },
    },
  },
}

vim.cmd.colorscheme "github_dark_dimmed"

vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"
