" escalt.vim    控制台下让用 <M-x> 也可用
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年12月14日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_escalt") || has("gui_running")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_escalt = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function Escalt_console()
  for i in range(65, 90)
    exe "set <M-".nr2char(i).">=\<Esc>".nr2char(i)
  endfor
  for i in range(97, 122)
    exe "set <M-".nr2char(i).">=\<Esc>".nr2char(i)
  endfor
  set ttimeoutlen=50
endfunction
" ---------------------------------------------------------------------
" Call Functions:
call Escalt_console()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
