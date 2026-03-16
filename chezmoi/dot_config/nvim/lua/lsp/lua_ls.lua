---@type vim.lsp.Config
local config = {
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
}

vim.lsp.config("lua_ls", config)
vim.lsp.enable("lua_ls")
