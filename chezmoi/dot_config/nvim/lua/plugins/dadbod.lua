vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/db_ui/tmp"

-- DuckDB adapter override: duckdb >= 1.5 renders `.tables` as an ANSI tree,
-- which tpope's tables() can't parse. duckdb_custom queries duckdb_tables()
-- instead, across all attached catalogs (see ~/.duckdbrc for the attach).
vim.g.db_adapter_duckdb = "db#adapter#duckdb_custom#"

-- Database connections: no paths in here — dadbod-ui reads DATABASE_URL
-- (exported from ~/.zshrc.local, the machine-local env layer).
-- Template for other connections (see the commented block below).
vim.g.db_ui_env_variable_url = "DATABASE_URL"

-- Completion for sql/mysql/plsql buffers
local cmp = require("cmp")
cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
  sources = cmp.config.sources({
    { name = "vim-dadbod-completion" },
  }, {
    { name = "buffer" },
  }),
})

-- Database connections
-- Snowflake:   snowflake://user:password@account.snowflakecomputing.com/database?warehouse=WH&role=ROLE&schema=SCHEMA
-- ClickHouse:  clickhouse://user:password@host:8123/database
-- vim.g.dbs = {
--   snowflake_dev  = "snowflake://user:password@account.snowflakecomputing.com/database?warehouse=WAREHOUSE&role=ROLE&schema=SCHEMA",
--   clickhouse_dev = "clickhouse://user:password@host:8123/database",
-- }

vim.keymap.set("n", "<leader>db", function()
  if vim.fn.executable("snowsql") == 0 then
    vim.notify("snowsql not found - install via: brew install --cask snowflake-snowsql", vim.log.levels.WARN)
  end
  vim.cmd("DBUIToggle")
end, { desc = "Toggle DB UI" })

return {
  { "tpope/vim-dadbod", cmd = { "DB", "DBUA" } },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIFindBuffer" },
    dependencies = { "tpope/vim-dadbod" },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
  },
}
