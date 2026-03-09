local jdtls = require("jdtls")
local mason_root = require("mason.settings").current.install_root_dir

-- Paths to Mason-installed packages
local jdtls_path = mason_root .. "/packages/jdtls"
local debug_adapter_path = mason_root .. "/packages/java-debug-adapter"
local java_test_path = mason_root .. "/packages/java-test"

-- Collect debug and test bundles
local bundles = {}
local debug_jar = vim.fn.glob(debug_adapter_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
if debug_jar ~= "" then
  table.insert(bundles, debug_jar)
end
local test_jars = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
for _, jar in ipairs(test_jars) do
  if jar ~= "" then
    table.insert(bundles, jar)
  end
end

-- Root detection
local root_dir = require("jdtls.setup").find_root({ "gradlew", "build.gradle", "pom.xml", ".git" })
if not root_dir then
  return
end

-- Per-project workspace directory
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- nvim-cmp capabilities (jdtls bypasses vim.lsp.config("*"))
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local config = {
  cmd = {
    jdtls_path .. "/bin/jdtls",
    "-configuration", jdtls_path .. "/config_mac",
    "-data", workspace_dir,
    "--jvm-arg=-Xmx4g",
  },
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.junit.jupiter.api.DynamicTest.*",
          "org.assertj.core.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
  },
  init_options = {
    bundles = bundles,
  },
}

jdtls.start_or_attach(config)

-- Buffer-local keymaps
local opts = { buffer = true }
vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract method" }))
vim.keymap.set("n", "<leader>jt", jdtls.test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test nearest method" }))
vim.keymap.set("n", "<leader>jT", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Test class" }))

-- Java buffer options
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
