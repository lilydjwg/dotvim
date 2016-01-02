" Vim syntax file
" FileType:    MediaWiki
" Author:      lilydjwg

" 很耗时的工作，所以少支持点儿。。。

" 所有未支持的类型
syntax region wikiCodePlain matchgroup=htmlTag start="^<syntaxhighlight [^>]\+>" end="^</syntaxhighlight>"
hi link wikiCodePlain Normal

let b:current_syntax_save = b:current_syntax

unlet b:current_syntax
syntax include @Python syntax/python.vim
syntax region wikiCodePython matchgroup=htmlTag start="<syntaxhighlight lang=python>" end="</syntaxhighlight>" contains=@Python
unlet b:current_syntax
syntax include @Xml syntax/xml.vim
syntax region wikiCodeXml matchgroup=htmlTag start="<syntaxhighlight lang=xml>" end="</syntaxhighlight>" contains=@Xml
unlet b:current_syntax
syntax include @C  syntax/c.vim
syntax region wikiCodeC matchgroup=htmlTag start="<syntaxhighlight lang=c>" end="</syntaxhighlight>" contains=@C
unlet b:current_syntax
let b:is_bash = 1 " 不要乱标示错误
syntax include @Bash  syntax/sh.vim
syntax region wikiCodeBash matchgroup=htmlTag start="<syntaxhighlight lang=bash>" end="</syntaxhighlight>" contains=@Bash
unlet b:current_syntax
syntax include @Lua  syntax/lua.vim
syntax region wikiCodeLua matchgroup=htmlTag start="<syntaxhighlight lang=lua>" end="</syntaxhighlight>" contains=@Lua
unlet b:current_syntax
syntax include @Javascript  syntax/javascript.vim
syntax region wikiCodeJavascript matchgroup=htmlTag start="<syntaxhighlight lang=javascript>" end="</syntaxhighlight>" contains=@Javascript

let b:current_syntax = b:current_syntax_save
unlet b:current_syntax_save
