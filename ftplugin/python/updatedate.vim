" Vim script file
" FileType:     Python
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-09-05
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("b:loaded_updatedate")
  finish
endif
let b:loaded_updatedate = 1
set cpo&vim
" ---------------------------------------------------------------------
function! s:updateDate()
  for i in range(1, 10)
    let line = getline(i)
    if line =~ '\v^\d{4}年\d+月\d+日$'
      call setline(i, Lilydjwg_zh_date())
      break
    endif
  endfor
endfunction
" ---------------------------------------------------------------------
au BufWritePre <buffer> call s:updateDate()
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
