-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- UI
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
---- Disable native mode indicator (mini.statusline shows it already)
vim.opt.showmode = false
---- Hide command line when not in use
vim.opt.cmdheight = 0
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"
vim.opt.termguicolors = true
vim.opt.wrap = false

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Scrolling
-- vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor
-- vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Swap/Backup/Undo files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Performance
vim.opt.updatetime = 250

-- Clipboard/Autoread
vim.opt.clipboard = "unnamedplus"
---- Auto-reload files changed outside Neovim (prevents W11 warning)
vim.opt.autoread = true
