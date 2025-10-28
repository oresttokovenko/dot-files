-- mini.statusline
require("mini.statusline").setup {
  use_icons = true,
  set_vim_settings = true,
}

-- mini.ai (text objects)
require("mini.ai").setup {
  n_lines = 500,
}

-- mini.comment
require("mini.comment").setup {
  options = {
    ignore_blank_line = true,
  },
}

-- mini.surround
require("mini.surround").setup {
  mappings = {
    add = "sa",
    delete = "sd",
    find = "sf",
    find_left = "sF",
    highlight = "sh",
    replace = "sr",
    update_n_lines = "sn",
  },
}

-- mini.operators
require("mini.operators").setup {
  evaluate = {
    prefix = "g=",
  },
  exchange = {
    prefix = "gx",
  },
  multiply = {
    prefix = "gm",
  },
  replace = {
    prefix = "gr",
  },
  sort = {
    prefix = "gs",
  },
}

-- mini.jump2d (flash.nvim style)
require("mini.jump2d").setup {
  view = {
    dim = true,
    n_steps_ahead = 2,
  },
  labels = "abcdefghijklmnopqrstuvwxyz",
  silent = false,
}

-- mini.pairs
require("mini.pairs").setup {}

-- mini.clue (which-key alternative)
local miniclue = require "mini.clue"
miniclue.setup {
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },

    -- Surround
    { mode = "n", keys = "s" },
    { mode = "x", keys = "s" },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },

  window = {
    delay = 200,
    config = {
      width = "auto",
      border = "rounded",
    },
  },
}

-- mini.notify
require("mini.notify").setup {
  content = {
    format = nil,
    sort = nil,
  },
  lsp_progress = {
    enable = true,
    duration_last = 1000,
  },
  window = {
    config = {
      border = "rounded",
    },
    max_width_share = 0.382,
    winblend = 0,
  },
}

-- Set mini.notify as the default notification handler
vim.notify = require("mini.notify").make_notify()
