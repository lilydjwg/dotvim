" Vim script file
" FileType:     lua
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011-03-08
" ---------------------------------------------------------------------
imap <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^--\s?$')<CR>
abbr <buffer> != ~=
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
