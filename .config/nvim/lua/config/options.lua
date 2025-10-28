vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.winborder = "rounded"

-- Keep signcolumn always visible to prevent shifting
vim.opt.signcolumn = "yes"

-- Disable native mode indicator (mini.statusline shows it already)
vim.opt.showmode = false

-- Auto-reload files changed outside Neovim
-- prevents a W11 warning when LLMs make changes to buffers
vim.opt.autoread = true
vim.opt.clipboard = "unnamedplus"

-- Enable current line highlighting but not for line numbers
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"  -- Only highlight the text line, not the number

-- Toggle relative/absolute line numbers based on mode
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({"InsertLeave"}, {
  callback = function()
    vim.opt.relativenumber = true
  end,
})
