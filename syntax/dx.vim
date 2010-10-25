" Vim script file
" FileType:    (短信)
" Author:      lilydjwg
" Last Change: 2009-01-29

syntax clear
syntax case match
syntax keyword dxTodo TODO FIXME XXX contained
syntax match dxTime /\s*\d\{4}-\d\{2}-\d\{2} \(\d\{2}\|--\):\(\d\{2}\|--\)\s\+/
syntax match dxTime /（时间未知）/
syntax match dxPerson /^.\{1,5}\(：\|:\)/
syntax region dxBold matchgroup=Identifier start==<b>= end==</b>=
syntax region dxCommentA start=/\/\// end=/$/ contains=dxTodo
syntax region dxCommentB start=/^——/ end=/$/ contains=dxTodo
syntax region dxModeline start=/^{{{ modeline/ end=/^}}}$/
highlight dxBold gui=bold term=bold cterm=bold
highlight link dxTime Special
highlight link dxPerson PreProc
highlight link dxCommentA Comment
highlight link dxCommentB Comment
highlight link dxModeline Ignore
highlight link dxTodo Todo
