" Vim syntax file
" FileType:     mb（mb 的命令文件）
" Author:      lilydjwg
" Last Change: 2009年11月25日

syntax clear
syntax case match
syntax match mbKeyword /\v^(ins(ert)?|a(dd)?)/
syntax match mbKeyword /\v^(set|wq)/
syntax match mbKeyword /\v^(d(el(ete)?)?|sd(el)?|strictdel|delcode|dc)/

highlight link mbKeyword Keyword
