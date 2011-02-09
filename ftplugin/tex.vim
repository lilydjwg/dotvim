" Vim script file
" FileType:     XeLaTeX
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2011年2月9日
" ---------------------------------------------------------------------
runtime ftplugin/texcommon.vim
nmap <buffer> <C-F5> :call texcommon#tex2pdf('xelatex')<CR>
setlocal conceallevel=2
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
