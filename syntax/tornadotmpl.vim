" Vim syntax file
" FileType:     Tornado template
" Author:       lilydjwg <lilydjwg@gmail.com>
" Version:	1.1

" Add something like the following in modeline to your templates:
" {# vim:se ft=html syntax=html.tornadotmpl: #}

syntax region tmplComment matchgroup=PreProc start="{#!\@!" end="#}"
syntax region tmplExpr    matchgroup=PreProc start="{{!\@!" end="}}"
      \ contains=@Python containedin=ALL
syntax region tmplCode    matchgroup=PreProc start="{%!\@!" end="%}"
      \ contains=tmplContent containedin=ALL
syntax region tmplCContent matchgroup=Keyword
      \ start="\v%(\{\%)@<=%(\s*)@>comment>"
      \ end="\%(%}\)\@="
      \ containedin=tmplCode
syntax region tmplContent matchgroup=Keyword
      \ start="\v%(\{\%)@<=%(\s*)@>%(apply|end|autoescape|block|extends|for|from|import|if|elif|else|include|module|raw|set|try|except|finally|while)>"
      \ end="\%(%}\)\@="
      \ contains=@Python containedin=tmplCode

let b:current_syntax_save = b:current_syntax
unlet b:current_syntax
syntax include @Python syntax/python.vim
let b:current_syntax = b:current_syntax_save
unlet b:current_syntax_save

highlight link tmplCode Normal
highlight link tmplExpr Normal
highlight link tmplComment Comment
highlight link tmplCContent Comment

set iskeyword-=58
