require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  -- Oil's s3 adapter shells out to `aws s3` and inherits nvim's env —
  -- launch nvim with AWS_PROFILE=<profile> (machine-local ~/.aws/config
  -- carries region/endpoint_url/creds per profile). Profile-agnostic.
})
