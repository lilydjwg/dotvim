" audioplaylist.vim   读写手机的 audio_play_list.txt 文件
" Author:       lilydjwg
" Last Change:  2010年2月23日
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_audioplaylist")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_audioplaylist = 1
set cpo&vim
" ---------------------------------------------------------------------
" Check:
"   check for our executable zhist
if !executable('auplst.py')
  finish
endif
" ---------------------------------------------------------------------
" Function:
function s:read(file)
  exe 'sil r!cat ''' . a:file . '''|auplst.py'
  1d
  " for mru.vim
  doautocmd BufReadPost
endfunction
function s:write(file)
  exe 'sil w !auplst.py write > ''' . a:file . ''''
  set nomodified
  " for mru.vim
  doautocmd BufWritePost
endfunction
" ---------------------------------------------------------------------
" Autocmds:
augroup audioplaylist.vim
 au!
 au BufReadCmd   audio_play_list.txt	call s:read(expand("<afile>"))
 au BufWriteCmd  audio_play_list.txt	call s:write(expand("<afile>"))
augroup END
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
