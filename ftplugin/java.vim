" Vim script file
" FileType:     Java
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-27

" ---------------------------------------------------------------------
inoremap <buffer> <silent> . .<C-X><C-O>
" 编译/运行设定
setlocal errorformat=%E%f:%l:\ %m,%-Z%p^,%+C%.%#,%-G.%#
function! s:MakeJava()
  let oldmakeprg = &l:makeprg
  if &fenc
    let &l:makeprg = 'javac -encoding ' . &fenc
  else
    setlocal makeprg=javac
  endif
  make %
  let &l:makeprg = oldmakeprg
endfunction

setlocal omnifunc=javacomplete#Complete
nmap <buffer> <silent> <C-CR> :update<CR>:call <SID>MakeJava()<CR>
" 如果用 cd，就可能覆盖掉本缓冲区的情况值
" 不回到原先的目录了，为了能够看到显示的信息
nmap <buffer> <silent> <S-F5> :lcd %:h<CR>:!java %:t:r<CR>
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
