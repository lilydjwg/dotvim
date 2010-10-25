" Vim script file
" FileType:     lrc 歌词
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009-07-04

" 合并歌词相同的行
nnoremap <buffer> ss ^d%v$hygg/<C-R>"<CR>"1P:nohls<CR><C-O><C-O>dd
" 删除不正确的行（不以 "[" 开头
nnoremap <buffer> sc :g/^\[\@!/d<CR>
