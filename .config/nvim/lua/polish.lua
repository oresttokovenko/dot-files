return function()
  -- Existing command
  vim.api.nvim_create_user_command("CopilotDisableFT", function(opts)
    local ft = opts.args
    if ft == "" then
      vim.notify("Please provide a filetype (e.g. :CopilotDisableFT cpp)", vim.log.levels.WARN)
      return
    end

    vim.g.copilot_filetypes = vim.g.copilot_filetypes or {}
    vim.g.copilot_filetypes[ft] = false

    vim.notify("Copilot disabled for filetype: " .. ft, vim.log.levels.INFO)
  end, {
    nargs = 1,
    complete = "filetype",
  })

  -- TODO: This doesn't actually work
  -- ToggleTerm-only ':' hijack -> exit terminal-insert and open Vim cmdline
  local function set_toggleterm_cmdline_map(bufnr)
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = bufnr, silent = true, desc = "Terminal → Normal" })
    -- Send ':' in terminal → Vim cmdline
    vim.keymap.set("t", ":", [[<C-\><C-n>:]], {
      buffer = bufnr,
      noremap = true,
      silent = true,
      desc = "ToggleTerm ':' → Neovim command-line",
    })
  end

  -- Apply the mapping only for ToggleTerm buffers
  vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    pattern = "term://*toggleterm#*",
    callback = function(ev)
      set_toggleterm_cmdline_map(ev.buf)
    end,
  })

  -- ToggleTerm keymaps
  -- vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "ToggleTerm horizontal" })
end
