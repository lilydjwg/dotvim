" Vim syntax file
" FileType:     HTML
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年5月23日

" ---------------------------------------------------------------------
syn include @htmlCss after/syntax/css/*.vim
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
