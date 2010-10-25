" zshhistfile.vim   使 zsh 的历史记录文件正常可读
" Author:       lilydjwg
" Last Change:  2010年8月27日
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_zshhistfile")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_zshhistfile = 1
set cpo&vim
" ---------------------------------------------------------------------
" Check:
"   check for our executable zhist
if !executable('zhist')
  finish
endif
" ---------------------------------------------------------------------
" Function:
function s:zshhistfileRead(file)
  " 保存当前的 fencs，因为文件中可能含有非 UTF-8 字符（比如用过 luit）而被 Vim
  " 误识别为 latin1等编码。
  " FIXME 转换失败不要使用问号代替
  let fencs = &fencs
  set fencs=utf8
  exe 'sil r!cat ''' . a:file . '''|zhist'
  let &fencs=fencs
  1d
  setf sh
  " for mru.vim
  doautocmd BufReadPost
endfunction
function s:zshhistfileWrite(file)
  exe 'sil w !zhist write > ''' . a:file . ''''
  set nomodified
  " for mru.vim
  doautocmd BufWritePost
endfunction
" ---------------------------------------------------------------------
" Autocmds:
augroup zshhistfile.vim
 au!
 au BufReadCmd   .histfile	call s:zshhistfileRead(expand("<afile>"))
 au BufWriteCmd  .histfile	call s:zshhistfileWrite(expand("<afile>"))
augroup END
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
