" Vim syntax file
" FileType:    ID3v2 (for the output of the python script 'id3v2editor')
" Author:      lilydjwg
" Last Change: 2009年8月5日

syntax clear
syntax case match
syntax region	id3v2Text	matchgroup=Delimiter start=/\(<<<\)\@<=\z(.*\)$/ end=/^\s*\z1\s*$/ contains=id3v2Name
syntax match	id3v2Name	/\v《\zs[^》]+\ze》/ contained
syntax match	id3v2lts	/<<</
syntax region	id3v2Comment	start=/#/ end=/$\|\(<<<\)\@=/ contains=id3v2note,id3v2quote
syntax match	id3v2Id		/^[[:alnum:]:'\\]\+/
syntax match	id3v2note	/\v注意\ze(：|:)|Note\ze:/ contained
syntax region	id3v2quote	start=/'/ end=/'/ contained oneline
syntax keyword	id3v2error	Traceback

highlight link id3v2Text	Normal
highlight link id3v2lts		Statement
highlight link id3v2Delimiter	Special
highlight link id3v2Comment	Comment
highlight link id3v2Id		Identifier
highlight link id3v2Name	String
highlight link id3v2note	PreProc
highlight link id3v2quote	String
highlight link id3v2error	Error
