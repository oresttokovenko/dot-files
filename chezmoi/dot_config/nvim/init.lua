vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Disable ocamllsp default keybindings
vim.g.ocaml_no_mappings = 1

-- vim.pack (0.12 nightly) has no built-in lazy loading, so we roll our own.
-- Plugins marked with `data = defer` are installed but not added to rtp at
-- startup. They are loaded on demand via vim.cmd.packadd() in keymaps/autocmds.
local defer = { defer = true }
local selective_load = function(plug_data)
  if (plug_data.spec.data or {}).defer then
    return
  end
  vim.cmd.packadd(plug_data.spec.name)
end

vim.pack.add({
  -- Dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },

  -- UI / Theme
  { src = "https://github.com/projekt0n/github-nvim-theme" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  ---- Only snacks.indent
  { src = "https://github.com/folke/snacks.nvim" },

  -- LSP / Completion
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },

  -- Treesitter / Syntax
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/folke/ts-comments.nvim" },

  -- File Navigation
  { src = "https://github.com/nvim-telescope/telescope.nvim", data = defer },
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Git Integration
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim", data = defer },

  -- Utilities
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/sourcegraph/amp.nvim" },
  { src = "https://github.com/coder/claudecode.nvim" },

  -- Database
  { src = "https://github.com/tpope/vim-dadbod" },
  { src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
  { src = "https://github.com/kristijanhusak/vim-dadbod-completion" },

  -- Language Specific (deferred)
  { src = "https://github.com/mfussenegger/nvim-jdtls" },
  { src = "https://github.com/linux-cultist/venv-selector.nvim", data = defer },
  { src = "https://github.com/OXY2DEV/markview.nvim", data = defer },
  { src = "https://github.com/chomosuke/typst-preview.nvim", data = defer },
  { src = "https://github.com/tlaplus-community/tlaplus-nvim-plugin", data = defer },
}, { load = selective_load })

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
require("plugins.amp")
require("plugins.claudecode")
require("plugins.nvim-cmp")
require("plugins.dadbod")
require("plugins.oil")
require("plugins.lint")

-- Deferred plugins (loaded on demand for faster startup)
-- telescope, diffview, venv-selector, typst-preview: loaded via keymaps in config/keymaps.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  once = true,
  callback = function()
    vim.cmd.packadd("markview.nvim")
    require("plugins.markview")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tla",
  once = true,
  callback = function()
    vim.cmd.packadd("tlaplus-nvim-plugin")
  end,
})
