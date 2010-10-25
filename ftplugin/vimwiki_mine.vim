" Vim script file
" FileType:     vimwiki
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年8月21日

nmap <buffer> <Space> <C-Space>
nmap <buffer> t8 I  * <ESC>
nmap <buffer> <C-CR> :VimwikiAll2HTML<CR><CR>
nmap <buffer> m~ i~~  ~~<ESC>2hi

vmap <buffer> m~ <ESC>`<I~~ <esc>`>A ~~<esc>
vmap <buffer> m{ <ESC>`<i[<ESC>`>a]<ESC>
vmap <buffer> m} <ESC>`>a]<ESC>`<i[<ESC>
vmap <buffer> m[ <ESC>`>a]]<ESC>`<i[[<ESC>
vmap <buffer> m] <ESC>`>a]]<ESC>`<i[[<ESC>f];

setlocal nonumber
setlocal nolbr
setlocal fo+=B
" 不能设置在 .vimrc 里，因为那里 wiki 变量还未被建立
" 直接打开文件时无效
" 如果 {{{ 不在行首亦无效
let wiki.nested_syntaxes = {'sh': 'sh', 'c': 'c'}

imap <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^\s*[*-]( \[.\])? $')<CR>

