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
if !exists("g:dictfilePrefix")
  if (has("win32") || has("win64"))
    let g:dictfilePrefix = '$VIM/vimfiles/dict/'
  else
    let g:dictfilePrefix = '~/.vim/dict/'
  endif
endif
" ---------------------------------------------------------------------
" Functions:
function SetDictFile(ft)
  let fname = g:dictfilePrefix . a:ft . '.txt'
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
  exe 'tabe '.g:dictfilePrefix.ft.'.txt|setlocal complete=w,b'
endfunction
function s:AddCurrent(file)
  let name = g:dictfilePrefix . a:file
  let word = expand("<cword>")
  try
    let f = readfile(name)
  catch /^Vim\%((\a\+)\)\=:E484/
    let f = []
  endtry
  let f = add(f, word)
  call writefile(f, name)
  echon word . " has been added to " . a:file
endfunction
" ---------------------------------------------------------------------
" Autocmds:
au BufReadPost,BufNewFile,FileType	* call SetDictFilePre()
" ---------------------------------------------------------------------
" Commands:
command -nargs=? Dict silent call OpenDict("<args>")
" ---------------------------------------------------------------------
" Setup:
exe "set dict+=" . escape(g:dictfilePrefix . '_.txt', ' \')
nmap <unique> <silent> g<Space> :call <SID>AddCurrent("_.txt")<CR>
nmap <unique> <silent> z<Space> :call <SID>AddCurrent(&ft . ".txt")<CR>
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo = s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
