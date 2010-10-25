" Vim script file
" FileType:     man
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年1月18日

" FIXME 中文文档无法显示中文

setlocal nonumber

nmap <buffer> q <C-W>q

" 把光标尽量放中间
let s:so=&so
au BufEnter,FileType,VimEnter <buffer> set scrolloff=50
au BufLeave <buffer> let &scrolloff=s:so
