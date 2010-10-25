" Vim syntax file
" FileType:     muttrc
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-09-22

" ---------------------------------------------------------------------
syn match muttrcAliasKey	contained /\s*[^- \t]\S*/ skipwhite nextgroup=muttrcAliasEmail,muttrcAliasEncEmail,muttrcAliasNameNoParens,muttrcAliasENNL
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
