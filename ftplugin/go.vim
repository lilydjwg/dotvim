" Vim script file
" FileType:     Go
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
setlocal noexpandtab tabstop=2
nmap <buffer> <C-CR> <Plug>(go-build)
nmap <buffer> <S-F5> <Plug>(go-run)
if exists(":GoImports")
  autocmd BufWritePre <buffer> GoImports
endif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
