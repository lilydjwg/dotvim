" Vim syntax file
" FileType:     Javascript
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年4月28日

" ---------------------------------------------------------------------
" 为 node.js 而加
syn match javaScriptLineComment /^\%1l#!.*$/
runtime! syntax/jquery.vim
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
