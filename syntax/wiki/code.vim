" Vim syntax file
" FileType:    MediaWiki
" Author:      lilydjwg

" 很耗时的工作，所以少支持点儿。。。

" 所有未支持的类型
syntax region wikiCodePlain matchgroup=htmlTag start="<code \w\+>" end="</code>"
hi link wikiCodePlain Normal

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
unlet b:current_syntax
syntax include @Lua  syntax/lua.vim
syntax region wikiCodeLua matchgroup=htmlTag start="<code lua>" end="</code>" contains=@Lua
unlet b:current_syntax
syntax include @Javascript  syntax/javascript.vim
syntax region wikiCodeJavascript matchgroup=htmlTag start="<code javascript>" end="</code>" contains=@Javascript
unlet b:current_syntax
