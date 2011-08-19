" Vim syntax file
" FileType:    python
" Author:      lilydjwg
" Last Change: 2009年8月30日

" CGI 中很多 HTML 字符串的
if expand('%:p') =~ 'www'
  unlet b:current_syntax
  syntax include @Html syntax/html.vim
  syntax region pythonHtmlString matchgroup=Normal start="r'''<\@=" end="'''" contains=@Html
  let b:current_syntax = 'python'
endif

syn region pythonString		start=+"""+ end=+"""+ keepend contains=pythonEscape,pythonEscapeError,pythonDocTest2,@Spell
syn region pythonString		start=+'''+ end=+'''+ keepend contains=pythonEscape,pythonEscapeError,pythonDocTest,@Spell
