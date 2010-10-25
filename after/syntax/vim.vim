" Vim syntax file
" Language:	Vim 7.2 script
" Last Change:	2009年8月10日
" Maintainer:	lilydjwg

" python 应该可以写在函数等之中
syn region vimPythonRegion fold matchgroup=vimScriptDelim start=+py\%[thon]\s*<<\s*\z(.*\)$+ end=+^\z1$+ contains=@vimPythonScript containedin=ALL
