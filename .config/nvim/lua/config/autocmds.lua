-- Reset maximized state when opening a terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function() vim.t.maximized = false end,
})

-- Toggle relative/absolute line numbers based on mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  callback = function() vim.opt.relativenumber = false end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  callback = function() vim.opt.relativenumber = true end,
})
