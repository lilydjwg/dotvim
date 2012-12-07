" escalt.vim    控制台下让用 <M-x> 也可用
" Author:       lilydjwg <lilydjwg@gmail.com>
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
  " 10, 22, 34, 62, 124 can't be set
  set <M-,>=,
  set <M-.>=.
  set ttimeoutlen=50
  " xterm keys, may also work in tmux with xterm-keys on
  set <F1>=OP
  set <F2>=OQ
  set <F3>=OR
  set <F4>=OS
  set <Home>=OH
  set <End>=OF
  set <S-Delete>=[3;2~
  if exists("$TMUX")
    set <S-F1>=[1;2P
    set <S-F2>=[1;2Q
    set <S-F3>=[1;2R
    set <S-F4>=[1;2S
    set <S-F5>=[15;2~
    set <S-F6>=[17;2~
    set <S-F7>=[18;2~
    set <S-F8>=[19;2~
    set <S-F9>=[20;2~
    set <S-F10>=[21;2~
    set <S-F11>=[23;2~
    set <S-F12>=[24;2~
    set <Home>=[1~
    set <End>=[4~
    " In xterm and tmux
    " 2 & 3 are Ins and Del, 5 & 6 are PgUp and PgDn
  elseif &term == 'linux'
    " Linux console keys, only S-F3 & S-F5 actually works
    " set <S-F1>=[25~
    " set <S-F2>=[26~
    set <S-F3>=[28~
    " set <S-F4>=[29~
    set <S-F5>=[31~
    " set <S-F6>=[32~
    " set <S-F7>=[33~
    " set <S-F8>=[34~
  else
    set <S-F1>=O1;2P
    set <S-F2>=O1;2Q
    set <S-F3>=O1;2R
    set <S-F4>=O1;2S
  endif
endfunction
" ---------------------------------------------------------------------
" Call Functions:
call Escalt_console()
" ---------------------------------------------------------------------
" Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
