vim.lsp.enable("gradle_ls")

-- lspconfig ships gradle_ls with filetypes = { "groovy" }, so only plain
-- `*.gradle` files auto-attach. Kotlin-DSL builds use `*.gradle.kts`, which
-- nvim filetype-maps to `kotlin`; adding `kotlin` to the server config's
-- filetypes would pull gradle_ls onto ordinary .kt sources
-- beside kotlin_language_server, so attach manually for those buffers only.
-- Works for any checkout whose root holds settings.gradle or build.gradle.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "kotlin",
  description = "gradle_ls on Gradle build scripts",
  callback = function(args)
    if not args.file:match("%.gradle%.kts$") then
      return
    end
    local buf = args.buf
    if #vim.lsp.get_clients({ bufnr = buf, name = "gradle_ls" }) > 0 then
      return
    end
    local config = vim.lsp.config["gradle_ls"]
    if not config then
      return
    end
    vim.lsp.start(config, { bufnr = buf, _root_markers = config.root_markers })
  end,
})
