require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  -- NOTE: profile pinning moved OUT of the global config on purpose.
  -- It now lives in project-local `.nvim.lua` files (vim.o.exrc) so nvim
  -- stays profile-agnostic everywhere else ($AWS_PROFILE env decides).
  -- See ~/Development/definitive-guide-to-apache-iceberg/.nvim.lua for the
  -- one project that pins --profile polaris-local.
})
