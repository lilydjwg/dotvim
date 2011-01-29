" escalt.vim    控制台下让用 <M-x> 也可用
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年12月15日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_escalt") || has("gui_running") || has("win32") || has("win64")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_escalt = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function Escalt_console()
  for i in range(48, 57) + range(65, 90) + range(97, 122)
    exe "set <M-".nr2char(i).">=\<Esc>".nr2char(i)
  endfor
  set ttimeoutlen=50
  if &term =~ 'xterm'
    set <F1>=OP
    set <F2>=OQ
    set <F3>=OR
    set <F4>=OS
    set <Home>=OH
    set <End>=OF
  endif
  for i in ["", "c", "i", "x"]
    exe i . "map Ï1;2P <S-F1>"
    exe i . "map Ï1;2Q <S-F2>"
    exe i . "map Ï1;2R <S-F3>"
    exe i . "map Ï1;2S <S-F4>"
  endfor
endfunction
" ---------------------------------------------------------------------
" Call Functions:
call Escalt_console()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
