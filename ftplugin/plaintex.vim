" Vim script file
" FileType:     XeTeX (plaintex)
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年12月30日

runtime ftplugin/texcommon.vim

nmap <buffer> <C-CR> :call Lilydjwg_tex_pdf('xetex')<CR>
