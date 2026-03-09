local ns = vim.api.nvim_create_namespace("jsonlines")

local function lint_jsonl(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local diagnostics = {}

  for i, line in ipairs(lines) do
    if line:match("%S") then
      local ok, err = pcall(vim.json.decode, line)
      if not ok then
        table.insert(diagnostics, {
          lnum = i - 1,
          col = 0,
          message = err,
          severity = vim.diagnostic.severity.ERROR,
          source = "jsonlines",
        })
      end
    end
  end

  vim.diagnostic.set(ns, bufnr, diagnostics)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  pattern = "*.jsonl",
  callback = function(ev)
    lint_jsonl(ev.buf)
  end,
})
