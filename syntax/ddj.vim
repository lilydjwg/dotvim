" Vim script file
" FileType:    (点滴集)
" Author:      lilydjwg
" Last Change: 2009-06-10

syntax clear
syntax case match
syntax match ddjName /《[^》]\+》/
syntax match ddjAuthor /（[^）]\+）/
syntax region ddjSource start=/^    ——/ end=/$/ keepend contains=ddjName,ddjAuthor,ddjLink
syntax match ddjLink /\v(https?|ftp):\/\/\S+/
syntax region ddjModeline start=/^{{{ modeline/ end=/^}}}$/
highlight link ddjName Special
highlight link ddjAuthor Comment
highlight link ddjSource PreProc
highlight link ddjLink Underlined
highlight link ddjModeline Ignore
