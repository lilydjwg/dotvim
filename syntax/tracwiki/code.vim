" Vim syntax file
" FileType:    TracWiki
" Author:      lilydjwg

let b:current_syntax_save = b:current_syntax

unlet b:current_syntax
syntax include @Javascript  syntax/javascript.vim
syntax region tracCodeJavascript matchgroup=PreProc start="{{{#!javascript" end="}}}" contains=@Javascript

let b:current_syntax = b:current_syntax_save
unlet b:current_syntax_save
