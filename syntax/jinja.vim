" Vim syntax file
" FileType:     jinja template
" Author:       lilydjwg <lilydjwg@gmail.com>
" Version:	0.1

runtime! syntax/tornadotmpl.vim

syntax region jinjaContent matchgroup=Keyword
      \ start="\v%(\{\%)@<=%(\s*)@>%(apply|end%(if|for|while|block|macro)|autoescape|block|extends|for|from|import|if|elif|else|include|module|raw|set|try|except|finally|while|macro)>"
      \ end="\%(%}\)\@="
      \ contains=@Python containedin=tmplCode

highlight link jinjiaContent tmplContent
