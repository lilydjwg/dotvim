" Vim script file
" FileType:    lrc 歌词
" Author:      lilydjwg
" Last Change: 2009年9月7日

syntax clear
syntax case match
syntax match	lrcInfo		/\v(^|\]@<=)\[[^]]+\]/ contains=lrcKeyword,lrcTime,lrcPunc
syntax keyword	lrcKeyword	al ar ti by offset contained
syntax match	lrcTime		/\v\d{2}:\d{2}(.\d{2})?/ contained contains=lrcPunc
syntax match	lrcPunc		/\v:|\./ contained
highlight link lrcInfo		PreProc
highlight link lrcTime		Number
highlight link lrcKeyword	Type
highlight link lrcPunc		Delimiter
