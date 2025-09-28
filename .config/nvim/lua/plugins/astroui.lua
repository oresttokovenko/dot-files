---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "github_dark_dimmed",
    -- highlight overrides
    highlights = {
      init = {
        -- transparent statusline with conditional text color
        -- white text if dark
        StatusLine = vim.o.background == "dark" and { bg = "NONE", fg = "#FFFFFF" }
          -- else transparent, keep fg as theme default
          or { bg = "NONE" },
        StatusLineNC = { bg = "NONE", fg = "#888888" },
      },
      astrodark = {
        -- per-theme overrides if you want
      },
    },
    -- icons
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
