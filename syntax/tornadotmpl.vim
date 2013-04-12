" Vim syntax file
" FileType:     Tornado template
" Author:       lilydjwg <lilydjwg@gmail.com>

" Add something like the following in modeline to your templates:
" {# vim:se syntax=html.tornadotmpl: #}

syntax region tmplCode matchgroup=PreProc start="{[%{]!\@!" end="[%}]}" contains=@Python,tmplKeyword containedin=ALL
syntax region tmplComment matchgroup=PreProc start="{#!\@!" end="#}"
syntax region tmplComment matchgroup=PreProc start="{%\s\+comment\s\+" end="%}"
syntax keyword tmplKeyword end include apply autoescape block extends module raw set

let b:current_syntax_save = b:current_syntax
unlet b:current_syntax
syntax include @Python syntax/python.vim
let b:current_syntax = b:current_syntax_save
unlet b:current_syntax_save

highlight link tmplCode Normal
highlight link tmplComment Comment
highlight link tmplKeyword Keyword
