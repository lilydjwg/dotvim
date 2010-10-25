" Vim script file
" FileType:     snipMate's snippets
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年1月23日

setlocal shiftwidth=2
setlocal softtabstop=0
inoremap <buffer> <CR> <CR><Tab>

setlocal fdm=expr
setlocal fde=getline(v:lnum)!~'^\\t\\\\|^$'?'>1':1
