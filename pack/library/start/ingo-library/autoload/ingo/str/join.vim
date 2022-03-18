" ingo/str/join.vim: Functions for joining lists of strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.001	24-Feb-2015	file creation

function! ingo#str#join#NonEmpty( list, ... )
    return call('join', [filter(a:list, '! empty(v:val)')] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
