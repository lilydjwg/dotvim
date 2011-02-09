" Vim script file
" FileType:     XeTeX (plaintex)
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2011年2月9日
" ---------------------------------------------------------------------
runtime ftplugin/texcommon.vim
nmap <buffer> <C-F5> :call texcommon#tex2pdf('xetex')<CR>
setlocal conceallevel=2
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
