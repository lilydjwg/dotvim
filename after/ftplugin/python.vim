" Vim script file
" FileType:     Python
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011年1月29日

" ---------------------------------------------------------------------
"  这可是全局选项！
set wildignore-=*.pyc
"  自带的配置会在任何时候都设置为 pythoncomplete#Complete
if has("python3")
  setlocal omnifunc=python3complete#Complete
elseif has("python")
  setlocal omnifunc=pythoncomplete#Complete
else
  setlocal omnifunc=syntaxcomplete#Complete
endif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
