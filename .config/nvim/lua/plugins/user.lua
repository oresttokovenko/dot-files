-- @type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
    },
  },
  -- Toggle line and block comments
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function() require("Comment").setup() end,
  },
  -- Navigating code
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = true } } },
    keys = {
      { "<leader>s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      {
        "<leader>S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
    },
  },
  -- LLM Autocomplete Integration
  -- TODO: enable Copilot only if the buffer has an attached LSP or a parser from Treesitter
  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- disable default Tab mapping
      vim.g.copilot_no_tab_map = true

      -- set filetype restrictions
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
        ["neo-tree"] = false,
        ["help"] = false,
        ["gitcommit"] = false,
      }

      -- map Shift+Enter to accept Copilot suggestion
      vim.keymap.set(
        "i",
        "<S-CR>",
        function() return vim.fn["copilot#Accept"] "<CR>" end,
        { expr = true, replace_keycodes = false }
      )
    end,
  },
  -- Markdown Support
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        -- tree always follows nvim's cwd
        bind_to_cwd = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
  -- Toggle brace autopairs
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  -- Override enter so that it auto selects the first completion item
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts = opts or {}
      opts.keymap = opts.keymap or {}

      opts.keymap.preset = opts.keymap.preset or "default"

      -- Make <CR> accept the first item (or current selection), otherwise newline
      opts.keymap["<CR>"] = {
        -- this is equivalent to: function(cmp) return cmp.select_and_accept() end
        "select_and_accept",
        "fallback",
      }
      return opts
    end,
  },
  -- Leetcode intergration
  {
    "kawre/leetcode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "python",
    },
  },
  {
    "VonHeikemen/fine-cmdline.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        smartHistory = true,
      },
      popup = {
        border = {
          style = "double",
        },
      },
    },
    keys = {
      { ":", "<cmd>FineCmdline<CR>", mode = "n", noremap = true, silent = true },
    },
  },
}
