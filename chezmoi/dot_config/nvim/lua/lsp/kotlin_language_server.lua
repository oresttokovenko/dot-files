-- fwcd's kotlin-language-server resolves classpaths for *.kt sources and
-- *.gradle.kts scripts by spawning Gradle in the project. Builds that register
-- duplicate subprojects (one directory, several projects — Polaris does this
-- by design) make plain Gradle refuse, starving all navigation. IntelliJ sets
-- `-Didea.active` for exactly this; mirror it into the spawned Gradle runs
-- via GRADLE_OPTS, which Gradle applies as a build-start system property.
vim.lsp.enable("kotlin_language_server")
vim.lsp.config("kotlin_language_server", {
  cmd_env = { GRADLE_OPTS = "-Didea.active=true" },
})
