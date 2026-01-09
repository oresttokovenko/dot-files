vim.keymap.set("i", "jk", "<Esc>")

-- General
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file", nowait = true })
vim.keymap.set("n", "<leader>W", "<cmd>wa<CR>", { desc = "Save all files" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all (force)" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd!<CR>", { desc = "Delete buffer (force)" })

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>li", "<cmd>checkhealth vim.lsp<CR>", { desc = "LSP info" })

-- ToggleTerm
vim.keymap.set("t", ";;", "<C-\\><C-n>", { desc = "Enter normal mode in terminal" })

-- Inline completion (Copilot ghost text)
vim.keymap.set("i", "<S-CR>", function()
  if not vim.lsp.inline_completion.get() then
    return "<CR>"
  end
end, { expr = true, replace_keycodes = true, desc = "Accept inline completion" })

vim.keymap.set("i", "<M-n>", function()
  vim.lsp.inline_completion.select({})
end, { desc = "Next inline completion" })

vim.keymap.set("i", "<M-p>", function()
  vim.lsp.inline_completion.select({ count = -1 })
end, { desc = "Previous inline completion" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
vim.keymap.set("n", "<C-M-h>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-M-l>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-M-k>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-M-j>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })

-- Window management
vim.keymap.set("n", "<leader>ov", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>oh", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })

-- Window maximize/zoom toggle
vim.keymap.set("n", "<leader>m", function()
  if vim.t.maximized then
    vim.cmd("wincmd =")
    vim.t.maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    vim.t.maximized = true
  end
end, { desc = "Toggle maximize window" })

vim.keymap.set({ "n", "v", "o" }, "H", "^")
vim.keymap.set({ "n", "v", "o" }, "L", "$")

vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent" })

vim.keymap.set({ "n", "v" }, "<leader>p", '"0p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"0P')

-- Copy current file path with @ prefix for LLM agents
vim.keymap.set("n", "<leader>yf", function()
  local filepath = vim.fn.expand("%")
  local formatted = "@" .. filepath
  vim.fn.setreg("+", formatted)
  vim.fn.setreg("*", formatted)
  vim.notify("Copied: " .. formatted)
end, { desc = "Copy file path with @ prefix" })

vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Oil.nvim buffer-local keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(args)
    vim.keymap.set("n", "<BS>", "-", { buffer = args.buf, desc = "Go to parent directory", remap = true })
  end,
})

-- Telescope
local builtin = require("telescope.builtin")

-- Find files
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fa", function()
  builtin.find_files({ hidden = true, no_ignore = true })
end, { desc = "Find all files" })

-- Find words
vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find words" })
vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find word under cursor" })

-- Find buffers
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })

-- Find recent
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find recent files" })

-- Find help/docs
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
vim.keymap.set("n", "<leader>fm", builtin.man_pages, { desc = "Find man pages" })

-- Find Neovim
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
vim.keymap.set("n", "<leader>fC", builtin.commands, { desc = "Find commands" })

-- Git
vim.keymap.set("n", "<leader>gt", builtin.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })

-- Gitsigns
local gitsigns = require("gitsigns")
vim.keymap.set("n", "hn", gitsigns.next_hunk, { desc = "Next git hunk" })
vim.keymap.set("n", "hp", gitsigns.prev_hunk, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview git hunk" })
vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage git hunk" })
vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset git hunk" })
vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
vim.keymap.set("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff this" })
vim.keymap.set("n", "<leader>gB", gitsigns.blame_line, { desc = "Blame line" })

-- Diffview
vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<CR>", { desc = "Open diffview" })
vim.keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current file history" })

-- Venv Selector
vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })
vim.keymap.set("n", "<leader>vc", "<cmd>VenvSelectCached<CR>", { desc = "Select cached venv" })

-- Typst Preview
vim.keymap.set("n", "<leader>pt", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle Typst preview" })

-- Mini.jump2d (flash-like navigation)
local jump2d = require("mini.jump2d")
-- Custom two-char jump (sneak-style)
vim.keymap.set("n", "<leader>s", function()
  local c1 = vim.fn.getcharstr()
  local c2 = vim.fn.getcharstr()
  jump2d.start({ spotter = jump2d.gen_spotter.pattern(vim.pesc(c1 .. c2)) })
end, { desc = "Jump to 2 chars" })
vim.keymap.set("n", "<leader>S", function()
  jump2d.start(jump2d.builtin_opts.line_start)
end, { desc = "Jump to line start" })
-- Old single-char mappings (commented out due to mini.surround conflict)
-- vim.keymap.set("n", "s", function()
--   jump2d.start(jump2d.builtin_opts.single_character)
-- end, { desc = "Jump to character" })
-- vim.keymap.set("n", "S", function()
--   jump2d.start(jump2d.builtin_opts.line_start)
-- end, { desc = "Jump to line start" })
