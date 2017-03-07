" Vim script file
" FileType:     Go
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
setlocal noexpandtab tabstop=2
nmap <buffer> <C-CR> <Plug>(go-build)
nmap <buffer> <S-F5> <Plug>(go-run)
if !exists('#GoImports') && executable("goimports")
  augroup GoImports
    au!
    autocmd BufWrite *.go silent call s:GoImports()
  augroup END
endif

function! s:GoImports()
  let pos = getpos('.')
  let na = line('$')
  %!goimports
  if v:shell_error
    undo
  endif
  let nb = line('$')
  let pos[1] = pos[1] + nb - na
  call setpos('.', pos)
endfunction
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
