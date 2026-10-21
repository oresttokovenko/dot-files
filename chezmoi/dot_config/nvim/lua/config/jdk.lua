-- Finds the JVM to host jdtls.
--
-- jdt.ls needs Java 21+ to run (its own `bin/jdtls` wrapper enforces that), but
-- the Eclipse platform bundles mason ships sometimes declare a newer osgi.ee
-- than that: the 1.62.0 snapshot requires JavaSE-25. So the server must run on
-- the newest JDK installed, independently of the 21 the project compiles for
-- (which Gradle's toolchain pins). Newest wins, so installing a newer JDK is
-- all it takes -- no version to edit here.
local M = {}

local MIN_MAJOR = 21 -- jdt.ls' own floor; raise if a newer snapshot lifts its BREE

local cache

--- Major version from a JDK home's `release` file, e.g. JAVA_VERSION="25.0.4.1".
local function major_of(java_home)
  local ok, lines = pcall(vim.fn.readfile, java_home .. "/release")
  if not ok then
    return nil
  end
  for _, line in ipairs(lines) do
    local major = line:match('^JAVA_VERSION="(%d+)')
    if major then
      return tonumber(major)
    end
  end
end

local function java_homes()
  local homes = {}
  if vim.env.JAVA_HOME then
    table.insert(homes, vim.env.JAVA_HOME)
  end
  vim.list_extend(homes, vim.fn.glob("~/.sdkman/candidates/java/*", false, true))
  vim.list_extend(homes, vim.fn.glob("~/Library/Java/JavaVirtualMachines/*/Contents/Home", false, true))
  return homes
end

--- Path to a `java` binary for jdtls, or nil to let jdtls use `java` on PATH.
function M.for_jdtls()
  if cache ~= nil then
    return cache or nil
  end

  local best_major, best_bin
  for _, home in ipairs(java_homes()) do
    local bin = home .. "/bin/java"
    if vim.fn.executable(bin) == 1 then
      local major = major_of(home)
      if major and major >= MIN_MAJOR and (not best_major or major > best_major) then
        best_major, best_bin = major, bin
      end
    end
  end

  cache = best_bin or false
  if not best_bin then
    vim.notify(
      "jdtls: no JDK " .. MIN_MAJOR .. "+ found, falling back to `java` on PATH",
      vim.log.levels.WARN
    )
  end
  return best_bin
end

return M
