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

-- Root detection: build-root markers only. Every subproject carries its own
-- build.gradle/pom.xml, so matching those attaches jdtls to a fragment of the
-- build and its Gradle sync fails to configure.
local root_dir = require("jdtls.setup").find_root({ "gradlew", "settings.gradle", "settings.gradle.kts", "mvnw", ".git" })
if not root_dir then
  root_dir = require("jdtls.setup").find_root({ "build.gradle", "build.gradle.kts", "pom.xml" })
end
if not root_dir then
  return
end

-- Per-project workspace directory; the hash stops two repos that share a
-- basename from sharing state.
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t") .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- nvim-cmp capabilities (jdtls bypasses vim.lsp.config("*"))
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- jdtls runs on the newest installed JDK (see config/jdk.lua), which is not
-- necessarily the 21 this project targets and Gradle compiles for.
local jdk = require("config.jdk")
local jdtls_java = jdk.for_jdtls()
-- The Gradle import runs in its own JVM, so it keeps the shell's JDK even when
-- the server itself needs a newer one.
local gradle_java_home = jdk.for_gradle()
-- Otherwise jdtls binds its own JVM as the project's default JRE.
local runtimes = jdk.runtimes(21)
local cmd = { jdtls_path .. "/bin/jdtls" }
if jdtls_java then
  vim.list_extend(cmd, { "--java-executable", jdtls_java })
end
vim.list_extend(cmd, {
  -- Writable OSGi state: the package's config_mac is the read-only shared area
  -- the wrapper already points at, and mason overwrites it on update.
  "-configuration", vim.fn.stdpath("state") .. "/jdtls-config",
  "-data", workspace_dir,
  "--jvm-arg=-Xmx4g",
})

local config = {
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      -- Flag mirror for runtime updates only (didChangeConfiguration after
      -- attach); jdt.ls reads import-time settings solely from
      -- init_options.settings below.
      configuration = {
        updateBuildConfiguration = "automatic",
        runtimes = runtimes,
      },
      import = {
        gradle = {
          annotationProcessing = { enabled = false },
          -- Builds may reject the newer JDK the server itself needs.
          java = { home = gradle_java_home },
        },
      },
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
    -- jdt.ls reads client settings ONLY from initializationOptions.settings at
    -- initialize (BaseInitHandler SETTINGS_KEY); the import job starts before
    -- the follow-up didChangeConfiguration lands, so the annotation-processing
    -- flag must ride here to reliably disable the failing APT model build.
    settings = {
      java = {
        configuration = {
          updateBuildConfiguration = "automatic",
          runtimes = runtimes,
        },
        import = {
          gradle = {
            annotationProcessing = { enabled = false },
            -- Same reason as the mirror above: the Gradle daemon's JVM must be
            -- the one the build accepts, not the one jdtls itself runs on.
            java = { home = gradle_java_home },
            -- Multi-scala-version builds can register several subprojects that
            -- share one directory; buildship refuses to sync such a build
            -- unless `idea.active` is set, the flag IntelliJ sets itself and
            -- which those builds' settings.gradle.kts responds to.
            -- Delivered via `arguments` (TAPI withArguments): verified to
            -- reach providers.systemProperty in the settings phase even on a
            -- reused daemon. Do NOT pass it as jvmArguments: TAPI would spawn
            -- a daemon with only those opts, dropping the project's 4g heap.
            arguments = { "-Didea.active=true" },
          },
        },
      },
    },
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
