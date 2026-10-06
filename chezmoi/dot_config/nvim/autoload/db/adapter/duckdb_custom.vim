" duckdb adapter override for vim-dadbod.
" tpope's stock tables() parses `.tables` output, which duckdb >= 1.5 renders
" as an ANSI-colored tree — unparseable. This adapter queries duckdb_tables()
" directly instead, across ALL attached catalogs (e.g. polaris_catalog from
" ~/.duckdbrc), not just the main file. Activated via:
"   vim.g.db_adapter_duckdb = 'db#adapter#duckdb_custom#'
function! db#adapter#duckdb_custom#canonicalize(url) abort
  return db#url#canonicalize_file(a:url)
endfunction

function! db#adapter#duckdb_custom#test_file(file) abort
  if getfsize(a:file) < 100
    return
  endif
  let firstline = readfile(a:file, '', 1)[0]
  if firstline[8:11] ==# 'DUCK' || firstline =~# '^SQLite format 3\n'
    return 1
  endif
endfunction

function! s:path(url) abort
  let path = db#url#file_path(a:url)
  if path =~# '^[\/]\=$'
    if !exists('s:session')
      let s:session = tempname() . '.duckdb'
    endif
    let path = s:session
  endif
  return path
endfunction

function! db#adapter#duckdb_custom#dbext(url) abort
  return {'dbname': s:path(a:url)}
endfunction

function! db#adapter#duckdb_custom#command(url) abort
  return ['duckdb', s:path(a:url)]
endfunction

function! db#adapter#duckdb_custom#interactive(url) abort
  return db#adapter#duckdb_custom#command(a:url) + ['-column', '-header']
endfunction

function! db#adapter#duckdb_custom#tables(url) abort
  return split(join(db#systemlist(db#adapter#duckdb_custom#command(a:url) + [
        \ '-noheader', '-list', '-c',
        \ "select database_name || '.' || schema_name || '.' || table_name"
        \ . " from duckdb_tables()"
        \ . " where database_name not in ('system', 'temp')"
        \ . " and schema_name <> 'information_schema'"])))
endfunction
