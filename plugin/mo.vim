" mo.vim	将 mo 文件转成 po 文件以供阅读/编辑，写入时再转回去
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年8月27日
" License:	Vim License  (see vim's :help license)

" Load Once:
if &cp || exists("g:loaded_mo")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_mo = 1
set cpo&vim
" ---------------------------------------------------------------------
" Function:
function s:mofileRead(file)
  exe 'sil r!msgunfmt ''' . a:file . ''''
  1d
  setf po
  " for mru.vim
  doautocmd BufReadPost
endfunction
function s:mofileWrite(file)
  exe 'sil w !msgfmt - -o ''' . a:file . ''''
  set nomodified
  " for mru.vim
  doautocmd BufWritePost
endfunction
" ---------------------------------------------------------------------
" Autocmds:
augroup mo.vim
 au!
 au BufReadCmd   *.mo	call s:mofileRead(expand("<afile>"))
 au BufWriteCmd  *.mo	call s:mofileWrite(expand("<afile>"))
augroup END
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
