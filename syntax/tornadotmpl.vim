" Vim syntax file
" FileType:     Tornado template
" Author:       lilydjwg <lilydjwg@gmail.com>
" Version:	1.2

" Add something like the following in modeline to your templates:
" {# vim:se ft=html syntax=html.tornadotmpl: #}

syntax region tmplComment matchgroup=PreProc start="{#!\@!" end="#}"
syntax region tmplExpr    matchgroup=PreProc start="{{!\@!" end="}}"
      \ contains=@Python containedin=ALLBUT,tmpl.*
syntax region tmplCode    matchgroup=PreProc start="{%!\@!" end="%}"
      \ contains=tmplContent containedin=ALLBUT,tmpl.*
syntax region tmplCContent matchgroup=Keyword
      \ start="\v%(\{\%)@<=%(\s*)@>comment>"
      \ end="\%(%}\)\@="
      \ containedin=tmplCode
syntax region tmplContent matchgroup=Keyword
      \ start="\v%(\{\%)@<=%(\s*)@>%(apply|end|autoescape|block|extends|for|from|import|if|elif|else|include|module|raw|set|try|except|finally|while)>"
      \ end="\%(%}\)\@="
      \ contains=@Python containedin=tmplCode

try
  let b:current_syntax_save = b:current_syntax
  unlet b:current_syntax
catch /.*/
endtry
syntax include @Python syntax/python.vim
try
  let b:current_syntax = b:current_syntax_save
  unlet b:current_syntax_save
catch /.*/
  unlet b:current_syntax
endtry

highlight link tmplCode Normal
highlight link tmplExpr Normal
highlight link tmplComment Comment
highlight link tmplCContent Comment

setlocal iskeyword-=58
