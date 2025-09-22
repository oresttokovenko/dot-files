return function()
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
  -- open a new floating terminal with <leader>tt
  -- vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "ToggleTerm horizontal" })
end
