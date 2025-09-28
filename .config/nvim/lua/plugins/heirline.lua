return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    -- Only show one (main) LSP client name instead of all active clients
    local main_lsp = {
      provider = function()
        local buf_ft = vim.bo.filetype
        local clients = vim.lsp.get_clients { bufnr = 0 }
        for _, client in ipairs(clients) do
          local fts = client.config and client.config.filetypes
          if fts and vim.tbl_contains(fts, buf_ft) then return client.name end
        end
        return ""
      end,
      hl = { fg = "#FFFFFF", bold = true },
    }

    -- Getting rid of the separators for a cleaner look
    require("astroui").setup {
      status = {
        separators = {
          left = { "" },
          right = { "" },
          tab = { left = { "" }, right = { "" } },
        },
      },
    }

    -- TODO: Fix this hacky padding
    opts.statusline = {
      -- Using colours from the theme
      hl = { fg = "fg", bg = "bg" },
      status.component.mode {
        mode_text = { padding = { left = 1, right = 1 } },
        surround = { separator = "none" },
        hl = { fg = "#FFFFFF" }
      },
      status.component.git_branch {
        padding = { left = 2 },
        surround = { separator = "none" },
        hl = { bg = "NONE" },
      },
      status.component.git_diff(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.virtual_env {
        padding = { right = 2 }
      },
      main_lsp,
      status.component.nav {
        padding = { left = 1 }
      },
    }
  end,
}
