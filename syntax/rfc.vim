" Vim syntax file
" Filetype:	RFC
" Author:	lilydjwg <lilydjwg@gmail.com>
" Version:	1.0

syntax clear
syntax case match

syn match rfcTitle	/^\v(\n)@<!\S.*$/
" syn match rfcTheTitle	/^\v\s{7,40}\S.*$/
" Find and highlight the Title
for i in range(1, 30)
  exe 'syn match rfcTheTitle /^\v%'.i.'l\s{4,40}\S.*$/'
endfor
unlet i
syn match rfcRFCTitle	/^\v(\n)@<=RFC.*$/
" RFC xxxx or ANSI X3.4-1986 like.
" FIXME I really don't know what will follow ANSI so there may be mistakes
syn match rfcRFC	/\v.@<=RFC\s+[0-9]+|ANSI\s+[0-9A-Z-.]+/ containedin=ALL
syn match rfcReference	/^\@<!\[\w\+\]/
syn match rfcComment	/^\S.*\ze\n/
syn match rfcDots	/\v\.\.+\ze\d+$/ contained
syn match rfcContents	/^\v\s+(([A-Z]\.)?([0-9]+\.?)+|Appendix|Full Copyright Statement).*(\n.*)?(\s|\.)\d+$/ contains=rfcDots
syn keyword rfcNote	NOTE note: Note: NOTE: Notes Notes:
" Highlight [sic] here so it won't be highlighted as rfcReference
syn match rfcKeyword  "\(MUST\(\s*[ \n]\+\s*NOT\)*\|REQUIRED\|SHALL\(\s*[ \n]\+\s*NOT\)*\|SHOULD\(\s*[ \n]\+\s*NOT\)*\|RECOMMENDED\|MAY\|OPTIONAL\|\[sic\]\)"

hi link rfcTitle	Title
hi link rfcTheTitle	Type
hi link rfcRFCTitle	PreProc
hi link rfcNote		Todo
hi link rfcRFC		Number
hi link rfcComment	Comment
hi link rfcReference	Number
hi link rfcDots		Comment
hi link rfcContents	Tag
hi link rfcKeyword	Keyword

let b:current_syntax = "rfc"
