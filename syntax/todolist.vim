" Vim script file
" FileType:    Todolist
" Author:      lilydjwg <lilydjwg@gmail.com>
" Last Change: 2009年9月11日

syntax clear
syntax case match
syntax match	todolistTime		/\v\s@<=\d{4}-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}( |$)@=/
syntax match	todolistPriority	/\v\~{,4}\$?$/ contained
syntax region	todolistComment		start=/#/ end=/$/ containedin=ALL
syntax match	todolistDone		/\v^.*\$$/ contains=todolistPriority
syntax match	todolistPriorityO	/\v^.*\~{1}$/ contains=todolistPriority,todolistTime
syntax match	todolistPriorityU	/\v^.*\~{2}$/ contains=todolistPriority,todolistTime
syntax match	todolistPriorityI	/\v^.*\~{3}$/ contains=todolistPriority,todolistTime
syntax match	todolistPriorityIU	/\v^.*\~{4}$/ contains=todolistPriority,todolistTime
highlight link todolistTime		Number
highlight link todolistPriority		Ignore
highlight link todolistComment		Comment
highlight link todolistDone		Comment
highlight link todolistPriorityIU	Special
highlight link todolistPriorityI	PreProc
highlight link todolistPriorityU	Identifier
highlight link todolistPriorityO	Statement

" vim:nowrap
