" Vim script file
" FileType:     lua
" Author:       lilydjwg <lilydjwg@gmail.com>
" ---------------------------------------------------------------------
imap <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^--\s?$')<CR>
abbr <buffer> != ~=
" This got left out :-(
setlocal indentkeys+=0=else,0=elseif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
