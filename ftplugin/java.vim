" Vim script file
" FileType:     Java
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-27

" ---------------------------------------------------------------------
inoremap <buffer> <silent> . .<C-X><C-O>
" 编译/运行设定
let &l:makeprg = 'javac -encoding ' . &fenc
setlocal errorformat=%E%f:%l:\ %m,%-Z%p^,%+C%.%#,%-G.%#

nmap <buffer> <silent> <C-CR> :update<CR>:make %<CR>
" 如果用 cd，就可能覆盖掉本缓冲区的情况值
" 不回到原先的目录了，为了能够看到显示的信息
nmap <buffer> <silent> <S-F5> :lcd %:h<CR>:!java %:t:r<CR>
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
