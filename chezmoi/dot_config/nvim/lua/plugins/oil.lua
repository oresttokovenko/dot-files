require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  -- Oil's s3 adapter shells out to `aws s3 <args> + extra_s3_args` and
  -- inherits nvim's env. This flag pins the PoC profile (machine-local
  -- ~/.aws/config owns region/endpoint/creds). Remove the line to make oil
  -- profile-agnostic ($AWS_PROFILE env decides per shell instead).
  extra_s3_args = { "--profile", "polaris-local" },
})
