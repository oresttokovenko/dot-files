-- Override global handler to filter out file operation registrations
-- that use unsupported brace glob syntax (e.g. **/*.{mdx})
local original_handler = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "mdx_analyzer" then
    result.registrations = vim.tbl_filter(function(reg)
      return not reg.method:find("^workspace/%w+Files$")
    end, result.registrations)
  end
  return original_handler(err, result, ctx)
end

vim.lsp.enable("mdx_analyzer")
