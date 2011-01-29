" bash.vim      插入/命令模式下 bash 式键映射
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011年1月28日
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
function s:Bash_killline()
  " 插入模式 kill 一行剩余的字符，返回空字符串
  call setline('.', strpart(getline('.'), 0, col('.')-1))
  return ''
endfunction
function s:Bash_killline_cmd()
  " 命令模式 kill 一行剩余的字符，返回 <C-U> 加应显示的字符串
  return strpart(getcmdline(), 0, getcmdpos()-1)
endfunction
function s:Bash_setup()
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
  cmap <silent> <M-d> <C-\>e<SID>Bash_killline_cmd()<CR>
  inoremap <M-b> <S-Left>
  inoremap <M-f> <S-Right>
  " <M-d> 删除光标后的字符
  imap <silent> <M-d> <C-R>=<SID>Bash_killline()<CR>
  inoremap <M-h> <Del>
  for i in range(10)
    " 这里如用 <expr>，则 feedkeys 不起作用
    exec 'inoremap <silent> <M-' . i . '> <C-R>=<SID>Altnum('. i .')<CR>'
  endfor
endfunction
function s:Altnum(n)
  let showmode = &showmode
  set noshowmode
  let ncount = a:n
  echohl Macro
  echo 'arg: ' . ncount
  echohl None
  let nextchar = getchar()
  while nextchar >= 176 && nextchar <= 185
    let n = nextchar - 176
    let ncount .= n
    echohl Macro
    echo 'arg: ' . ncount
    echohl None
    let nextchar = getchar()
  endwhile
  if nextchar != 27 && nextchar != 3
    let input = repeat(nr2char(nextchar), ncount)
    call feedkeys(input, 'm')
  endif
  let &showmode = showmode
  return ''
endfunction
" ---------------------------------------------------------------------
"  Call Functions:
call s:Bash_setup()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
