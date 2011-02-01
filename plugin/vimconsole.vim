" vimconsole.vim 打开一个窗口来输入 Vimscript 代码，并在原窗口执行
" Author:       lilydjwg
" Last Change:  2011年1月30日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_vimconsole")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_vimconsole = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function s:VimConsole_init(nr)
  rightbelow 7split [VimConsole]
  set buftype=nofile
  set filetype=vim
  %d "清除模板之类的东西
  set nofoldenable
  let b:nr = a:nr
  nnoremap <buffer> <silent> q <C-W>c
  nnoremap <buffer> <silent> <C-CR> :call <SID>VimConsole_run()<CR>
  inoremap <buffer> <silent> <C-CR> <Esc>:call <SID>VimConsole_run()<CR>
  inoremap <buffer> <silent> <C-C> <Esc><C-W>c
  command! -buffer Run call s:VimConsole_run()
  if exists('g:VimCode')
    call setline(1, g:VimCode)
  else
    startinsert
  endif
endfunction
function s:VimConsole_run()
  let vim = tempname()
  exe 'w '. vim
  let self = winnr()
  exe b:nr.'wincmd w'
  sil exe "source ".vim
  exe self.'wincmd w'
  call delete(vim)

  if !exists("g:VimConsole_after") || g:VimConsole_after == 1 "关闭
    let g:VimCode = getline(1, '$')
    q
  elseif g:VimConsole_after == 2 "清空
    %d
  elseif g:VimConsole_after == 0 "无动作
  endif
endfunction
" ---------------------------------------------------------------------
" Commands:
command Vimconsole call s:VimConsole_init(winnr())
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
