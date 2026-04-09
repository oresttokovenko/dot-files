if vim.fn.executable("alloy") == 0 then
  error("alloy not found - install via: brew install alloy-analyzer")
end

vim.filetype.add({ extension = { als = "alloy" } })

vim.lsp.enable("alloy_ls")
