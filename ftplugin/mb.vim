" Vim script file
" FileType:     mb（mb 的命令文件）
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年11月25日

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" 重置选中的词
nmap <buffer> <Space> oset <C-R>*<Esc>
" 删除选中的词
nmap <buffer> <Tab> odel <C-R>*<ESC>
