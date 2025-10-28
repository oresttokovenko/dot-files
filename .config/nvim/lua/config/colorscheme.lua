require('github-theme').setup({
  groups = {
    all = {
      -- Colors from: https://github.com/projekt0n/github-nvim-theme/blob/main/lua/github-theme/palette/primitives/dark_dimmed.lua
      -- bg: #adbac7 (line 82: codemirror.cursor & line 405: fg.default) - softer white, not too bright
      -- fg: black - for high contrast against the cursor background
      Cursor = { fg = '#000000', bg = '#adbac7' },
      lCursor = { fg = '#000000', bg = '#adbac7' },
      TermCursor = { fg = '#000000', bg = '#adbac7' },
    },
  },
})

vim.cmd.colorscheme "github_dark_dimmed"

-- vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"
