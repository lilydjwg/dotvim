" Vim script file
" FileType:     Vim script
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年8月28日

" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_vimonce")
 finish
endif
let s:keepcpo = &cpo
let g:loaded_vimonce = 1
set cpo&vim
" ---------------------------------------------------------------------
function s:updateDate()
  for i in range(1, 5)
    let line = getline(i)
    if line =~ '^" Last Change:'
      call setline(i, '" Last Change:  '. strftime("%Y-%m-%d"))
      break
    endif
  endfor
endfunction
" ---------------------------------------------------------------------
au BufWritePre *.vim call s:updateDate()
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
