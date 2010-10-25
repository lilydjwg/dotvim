" Vim syntax file
" FileType:     Radio List（电台流媒体地址记载文件）
" Author:       lilydjwg
" Last Change:  2010年3月7日

syntax clear
syntax case match
syntax match	rlDate          /\(\<\d\{4}年\)\?\(\d\{1,2}\|元\)月\d\{1,2}日/
syntax match	rlLink		/\v(mms:|rtsp:|http:)[a-zA-Z0-9_:\/.-]+/
syntax match    rlDelim         /^[=-]\+$/
syntax region	rlModeline      start=/^vim:/ end=/$/

highlight link rlDate		Identifier
highlight link rlLink		Underlined
highlight link rlDelim		PreProc
highlight link rlModeline	Comment
