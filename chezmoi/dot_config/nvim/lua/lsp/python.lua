-- Auto-detect the Python LSP set from pyproject.toml sections.
-- Exactly one type checker attaches per project:
--   pyright       when [tool.pyright] is set and [tool.basedpyright] is not
--   ty            when [tool.ty] or ty.toml is set and neither pyright nor basedpyright is
--   basedpyright  otherwise (default)
-- Ruff attaches as a supplementary linter/formatter alongside whichever one wins.

local function has_section(root, section)
  local f = io.open(vim.fs.joinpath(root, "pyproject.toml"))
  if not f then
    return false
  end
  local content = f:read("*a")
  f:close()
  -- Match "[tool.ty]" and its subtables like "[tool.ty.src]"; dots are escaped so they match literally
  return content:find("%[" .. section:gsub("%.", "%%.") .. "[%]%.]") ~= nil
end

local function pyright_keep(root)
  return has_section(root, "tool.pyright") and not has_section(root, "tool.basedpyright")
end

local function ty_keep(root)
  return not has_section(root, "tool.basedpyright")
    and not has_section(root, "tool.pyright")
    and (has_section(root, "tool.ty") or vim.uv.fs_stat(vim.fs.joinpath(root, "ty.toml")) ~= nil)
end

-- Config goes through vim.lsp.config(): vim.lsp.enable()'s second argument is a boolean, not a config.
-- root_dir receives (bufnr, on_dir) and must call on_dir(root); a returned value is ignored.
local function configure(name, keep)
  vim.lsp.config(name, {
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, { "pyproject.toml", "ty.toml", ".git" })
      if root and keep(root) then
        on_dir(root)
      end
    end,
  })
  vim.lsp.enable(name)
end

configure("basedpyright", function(root)
  return not pyright_keep(root) and not ty_keep(root)
end)
configure("pyright", pyright_keep)
configure("ty", ty_keep)

configure("ruff", function(root)
  return has_section(root, "tool.ruff")
end)
