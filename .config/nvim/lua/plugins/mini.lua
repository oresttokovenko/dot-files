-- mini.statusline
require("mini.statusline").setup({
  use_icons = true,
  set_vim_settings = true,
})

-- Customize statusline sections
local statusline = require("mini.statusline")

-- Override location section to show percentage instead of line:column
statusline.section_location = function(args)
  if statusline.is_truncated(args.trunc_width) then return "%P" end
  return "%P"
end

-- Hide diagnostics (errors/warnings/info/hints)
statusline.section_diagnostics = function(args) return "" end

-- Override fileinfo to remove file size (keep filetype, encoding, format)
statusline.section_fileinfo = function(args)
  local filetype = vim.bo.filetype

  -- Add filetype icon (same logic as default)
  local mini_icons_available, mini_icons = pcall(require, "mini.icons")
  if mini_icons_available and filetype ~= "" then
    local icon, _, _ = mini_icons.get("filetype", filetype)
    filetype = icon .. " " .. filetype
  end

  -- Return just filetype if truncated or not normal buffer
  if statusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then return filetype end

  -- Show filetype, encoding, and format (NO file size)
  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  return string.format("%s%s%s[%s]", filetype, filetype == "" and "" or " ", encoding, format)
end

-- mini.ai (text objects)
require("mini.ai").setup({
  n_lines = 500,
})

-- mini.comment
require("mini.comment").setup({
  options = {
    ignore_blank_line = true,
  },
})

-- mini.surround
require("mini.surround").setup({
  mappings = {
    add = "sa",
    delete = "sd",
    find = "sf",
    find_left = "sF",
    highlight = "sh",
    replace = "sr",
    update_n_lines = "sn",
  },
})

-- mini.operators
require("mini.operators").setup({
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
})

-- mini.jump2d (flash.nvim style)
require("mini.jump2d").setup({
  mappings = {
    start_jumping = "",
  },
  view = {
    dim = true,
    n_steps_ahead = 2,
  },
  labels = "abcdefghijklmnopqrstuvwxyz",
  silent = false,
})

-- mini.pairs
require("mini.pairs").setup({})

-- mini.clue (which-key alternative)
local miniclue = require("mini.clue")
miniclue.setup({
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
})

-- mini.notify
require("mini.notify").setup({
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
})

-- Set mini.notify as the default notification handler
vim.notify = require("mini.notify").make_notify()
