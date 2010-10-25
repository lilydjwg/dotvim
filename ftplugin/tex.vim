" Vim script file
" FileType:     XeLaTeX
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年12月30日

runtime ftplugin/texcommon.vim

command! -buffer Make call Lilydjwg_tex_pdf('xelatex')
nmap <buffer> <C-CR> :call Lilydjwg_tex_pdf('xelatex')<CR>
