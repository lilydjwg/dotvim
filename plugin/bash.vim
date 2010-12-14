" bash.vim      插入/命令模式下 bash 式键映射
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年12月14日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_bash")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_bash = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function Bash_killline()
  " 插入模式 kill 一行剩余的字符，返回空字符串
  call setline('.', strpart(getline('.'), 0, col('.')-1))
  return ''
endfunction
function Bash_killline_cmd()
  " 命令模式 kill 一行剩余的字符，返回 <C-U> 加应显示的字符串[[[2
  return strpart(getcmdline(), 0, getcmdpos()-1)
endfunction
function Bash_setup()
  cnoremap <C-B> <Left>
  cnoremap <C-F> <Right>
  cnoremap <C-A> <C-B>
  inoremap <C-A> <Home>
  inoremap <C-E> <End>
  inoremap <C-B> <Left>
  inoremap <C-F> <Right>
  inoremap <C-P> <Up>
  inoremap <C-N> <Down>
  cnoremap <M-b> <S-Left>
  cnoremap <M-f> <S-Right>
  cnoremap <M-h> <Del>
  cmap <silent> <M-d> <C-\>eBash_killline_cmd()<CR>
  inoremap <M-b> <S-Left>
  inoremap <M-f> <S-Right>
  " <M-d> 删除光标后的字符
  imap <silent> <M-d> <C-R>=Bash_killline()<CR>
  inoremap <M-h> <Del>
endfunction
" ---------------------------------------------------------------------
"  Call Functions:
call Bash_setup()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
