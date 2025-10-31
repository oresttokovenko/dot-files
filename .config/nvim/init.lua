vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.pack.add({
  -- Dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },

  -- UI / Theme
  { src = "https://github.com/projekt0n/github-nvim-theme" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  ---- Only snacks.indent
  { src = "https://github.com/folke/snacks.nvim" },

  -- LSP / Completion
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },

  -- Treesitter / Syntax
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/folke/ts-comments.nvim" },

  -- File Navigation
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Git Integration
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },

  -- Utilities
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/sourcegraph/amp.nvim" },

  -- Language Specific
  { src = "https://github.com/linux-cultist/venv-selector.nvim" },
  { src = "https://github.com/OXY2DEV/markview.nvim" },
})

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.diagnostics")
require("config.lsp")
require("config.colorscheme")
require("plugins.devicons")
require("plugins.mini")
require("plugins.treesitter")
require("plugins.gitsigns")
require("plugins.snacks")
require("plugins.toggleterm")
require("plugins.ts-comments")
require("plugins.venv-selector")
require("plugins.markview")
require("plugins.diffview")
require("plugins.oil")
require("plugins.telescope")
require("plugins.amp")
require("plugins.nvim-cmp")
