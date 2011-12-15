" Vim syntax file
" FileType:    C/C++
" Author:      lilydjwg

syntax case match

" 在 MediaWiki 中，这样才正常
" 不要 keepend，结束的 </code> 不高亮；
if &ft == 'wiki'
  syntax region	cBlock		start="{" end="}" fold transparent keepend
endif
