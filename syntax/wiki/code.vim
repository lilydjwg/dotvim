" Vim syntax file
" FileType:    MediaWiki
" Author:      lilydjwg
" Last Change: 2010年8月26日

" 很耗时的工作，所以少支持点儿。。。

unlet b:current_syntax
syntax include @Python syntax/python.vim
syntax region wikiCodePython matchgroup=htmlTag start="<code python>" end="</code>" contains=@Python
unlet b:current_syntax
syntax include @Xml syntax/xml.vim
syntax region wikiCodeXml matchgroup=htmlTag start="<code xml>" end="</code>" contains=@Xml
unlet b:current_syntax
syntax include @C  syntax/c.vim
syntax region wikiCodeC matchgroup=htmlTag start="<code c>" end="</code>" contains=@C
unlet b:current_syntax
let b:is_bash = 1 " 不要乱标示错误
syntax include @Bash  syntax/sh.vim
syntax region wikiCodeBash matchgroup=htmlTag start="<code bash>" end="</code>" contains=@Bash
