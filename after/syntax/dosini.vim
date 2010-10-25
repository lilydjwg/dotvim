" Vim syntax file
" FileType:     dosini 补充
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年7月13日

" ---------------------------------------------------------------------
syn match  dosiniComment	"^[;#].*$"
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
