" Vim script file
" FileType:     TeX common settings
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011年2月9日
" ---------------------------------------------------------------------
nmap <buffer> <S-F5> :call texcommon#view()<CR>
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
