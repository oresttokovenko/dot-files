require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  -- Oil's stock s3 adapter shells out to `aws s3` — point it at the rustfs
  -- PoC via the machine-local "rustfs" profile (~/.aws/config: creds +
  -- endpoint_url). oil-s3://bucket123/ then browses object storage in-editor.
  extra_s3_args = { "--profile", "rustfs" },
})
