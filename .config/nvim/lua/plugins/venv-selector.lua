local function shorter_name(filename)
  return filename:gsub(os.getenv("HOME"), "~"):gsub("/bin/python", "")
end

require("venv-selector").setup({
  auto_refresh = true,
  options = {
    on_telescope_result_callback = shorter_name,
  },
})
