" pyconsole.vim 打开一个窗口来输入 Python 代码，并在原窗口执行
" Author:       lilydjwg
" Last Change:  2010年4月30日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_pyconsole")
  finish
endif
if !has("python")
  echohl ErrorMsg
  echomsg "PyConsole.vim needs vim with +python feature!"
  echohl None
  finish
endif
let s:keepcpo = &cpo
let g:loaded_pyconsole = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function s:PyConsole_init(nr)
  py import vim
  py v = vim;
  py b = v.current.buffer
  rightbelow 7split [PyConsole]
  set buftype=nofile
  set filetype=python
  %d "清除模板之类的东西
  let b:nr = a:nr
  nnoremap <buffer> <silent> q <C-W>c
  nnoremap <buffer> <silent> <C-CR> :call <SID>PyConsole_run()<CR>
  inoremap <buffer> <silent> <C-CR> <Esc>:call <SID>PyConsole_run()<CR>
  inoremap <buffer> <silent> <C-C> <Esc><C-W>c
  command! -buffer Run call s:PyConsole_run()
  if exists('g:PyCode')
    call setline(1, g:PyCode)
  else
    startinsert
  endif
endfunction
function s:PyConsole_run()
  let py = tempname()
  exe 'w'.py
  let self = winnr()
  exe b:nr.'wincmd w'
  sil exe "pyfile ".py
  exe self.'wincmd w'
  call delete(py)

  if !exists("g:PyConsole_after") || g:PyConsole_after == 1 "关闭
    let g:PyCode = getline(1, '$')
    q
  elseif g:PyConsole_after == 2 "清空
    %d
  elseif g:PyConsole_after == 0 "无动作
  endif
endfunction
" ---------------------------------------------------------------------
" Commands:
command Pyconsole call s:PyConsole_init(winnr())
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
