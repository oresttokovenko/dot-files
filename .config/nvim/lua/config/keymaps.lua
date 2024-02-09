-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<Esc>")

vim.keymap.set("n", "J", "5j")
vim.keymap.set("n", "J", "5j")

vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

vim.keymap.set("v", "J", "5j")
vim.keymap.set("v", "K", "5k")

vim.keymap.set("v", "H", "^")
vim.keymap.set("v", "L", "$")

vim.keymap.set("x", "<leader>p", '"_dP')