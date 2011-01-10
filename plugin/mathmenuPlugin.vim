" mathmenuPlugin.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Feb 03, 2010
"   Version: 3
" GetLatestVimScripts: 2723 1 :AutoInstall: math.vim
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_mathmenuPlugin")
 finish
endif
let s:keepcpo               = &cpo
let g:loaded_mathmenuPlugin = "v3"
set cpo&vim

" ---------------------------------------------------------------------
" DrChip Menu Support: {{{1
if has("gui_running") && has("menu") && &go =~ 'm'
 if !exists("g:DrChipTopLvlMenu")
  let g:DrChipTopLvlMenu= "DrChip."
 endif
 exe 'nmenu <silent> '.g:DrChipTopLvlMenu."MathKeys.Enable	:call mathmenu#StartMathKeytab()\<cr>"
 exe 'imenu <silent> '.g:DrChipTopLvlMenu."MathKeys.Enable	\<c-o>:call mathmenu#StartMathKeytab()\<cr>"
 exe 'vmenu <silent> '.g:DrChipTopLvlMenu."MathKeys.Enable	:\<c-u>call mathmenu#StartMathKeytab()\<cr>gv"
 exe 'cmenu <silent> '.g:DrChipTopLvlMenu."MathKeys.Enable	\<c-u>call mathmenu#StartMathKeytab()\<cr>:"
 com! MathStart	:call mathmenu#StartMathKeytab()
endif

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=28 fdm=marker
