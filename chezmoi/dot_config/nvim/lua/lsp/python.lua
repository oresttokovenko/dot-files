-- Auto-detect Python LSP from pyproject.toml sections.
-- basedpyright is the default type checker.
-- pyright wins only when explicitly configured and basedpyright isn't.
-- Ruff attaches as a supplementary linter/formatter alongside either type checker.

local function has_section(root, section)
  local path = vim.fs.joinpath(root, "pyproject.toml")
  local f = io.open(path)
  if not f then
    return false
  end
  local content = f:read("*a")
  f:close()
  -- Escape dots so "tool.basedpyright" matches literally
  return content:find("%[" .. section:gsub("%.", "%%.") .. "%]") ~= nil
end

local function pyproject_root(fname)
  return vim.fs.root(fname, { "pyproject.toml", ".git" })
end

-- Type checker: basedpyright (default) or pyright (explicit opt-in)
vim.lsp.enable("basedpyright", {
  root_dir = function(fname)
    local root = pyproject_root(fname)
    if not root then
      return nil
    end
    -- Skip if pyright is explicitly configured and basedpyright is not
    if has_section(root, "tool.pyright") and not has_section(root, "tool.basedpyright") then
      return nil
    end
    return root
  end,
})

vim.lsp.enable("pyright", {
  root_dir = function(fname)
    local root = pyproject_root(fname)
    if not root then
      return nil
    end
    if has_section(root, "tool.pyright") and not has_section(root, "tool.basedpyright") then
      return root
    end
    return nil
  end,
})

-- Ruff: supplementary linter/formatter
vim.lsp.enable("ruff", {
  root_dir = function(fname)
    local root = pyproject_root(fname)
    if not root then
      return nil
    end
    if has_section(root, "tool.ruff") then
      return root
    end
    return nil
  end,
})
