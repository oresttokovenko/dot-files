/** @type {import("./npm/node_modules/pi-vimmode/config").VimConfig} */
export default (vim) => {
  // Normal-mode remaps (literal key replay)
  vim.keymap.set("n", "m", "<C-l>");
  vim.keymap.set("n", "]m", "<C-p>");
  vim.keymap.set("n", "[m", "<C-S-p>");
  vim.keymap.set("n", "]t", "<S-Tab>");
  vim.keymap.set("n", "e", "<C-g>");

  // Pi commands from normal mode
  vim.keymap.set("n", "n", "i/new<CR>");
  vim.keymap.set("n", "r", "i/resume<CR>");
  vim.keymap.set("n", "q", ":q<CR>");
  vim.keymap.set("n", "x", ":q!<CR>");
};
