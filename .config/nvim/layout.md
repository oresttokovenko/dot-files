~/.config/nvim/
├─ init.lua
└─ lua/
   └─ my/
      ├─ config/
      │  ├─ options.lua        -- :set-equivalents (vim.opt…)
      │  ├─ keymaps.lua        -- vim.keymap.set…
      │  └─ autocmds.lua       -- vim.api.nvim_create_autocmd…
      ├─ core/
      │  ├─ lazy.lua           -- plugin manager bootstrap + require("lazy").setup
      │  └─ lsp.lua            -- global LSP wiring (mason, lspconfig, cmp glue)
      ├─ plugins/
      │  ├─ ui.lua             -- colorscheme, statusline, bufferline, etc.
      │  ├─ treesitter.lua     -- nvim-treesitter spec & config
      │  ├─ tools.lua          -- telescope, gitsigns, which-key, etc.
      │  └─ editing.lua        -- autopairs, comment, surround, better-escape…
      └─ utils/
         └─ init.lua           -- helper funcs (safe_require, on_attach, icons…)
