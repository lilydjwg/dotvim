" dictfile.vim  自动设置 'dict' 选项
" Author:       lilydjwg
" Last Change:  2010-09-06
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_dictfile")
 finish
endif
let s:keepcpo = &cpo
let g:loaded_dictfile = 1
set cpo&vim
" ---------------------------------------------------------------------
" Variables:
if (has("win32") || has("win95") || has("win64") || has("win16"))
  let s:dictfilePrefix = '$VIM/vimfiles/dict/'
else
  let s:dictfilePrefix = '~/.vim/dict/'
endif
" ---------------------------------------------------------------------
" Functions:
function SetDictFile(ft)
  let fname = s:dictfilePrefix . a:ft . '.txt'
  let fname = expand(fname)
  if filereadable(fname)
    exe "setlocal dict+=" . escape(fname, ' \')
    setlocal complete+=k
  endif
endfunction
function SetDictFilePre()
  call SetDictFile(&ft)
  if &ft =~ '\v^(x?html|php)$'
    call SetDictFile('css')
    call SetDictFile('javascript')
    call SetDictFile('dom')
  elseif &ft =~ '\v^(javascript|python)$'
    call SetDictFile('dom')
    call SetDictFile('jquery')
  endif
endfunction
function OpenDict(ft)
  let ft = a:ft
  if ft == ''
    let ft = &ft
  endif
  exe 'tabe '.s:dictfilePrefix.ft.'.txt|setlocal complete=w,b'
endfunction
" ---------------------------------------------------------------------
" Autocmds:
au BufReadPost,BufNewFile,FileType	* call SetDictFilePre()
" ---------------------------------------------------------------------
" Commands:
command -nargs=? Dict silent call OpenDict("<args>")
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo = s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
