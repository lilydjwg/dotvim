" ingo/collections/rotate.vim: Functions to rotate items in a List.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.001	25-May-2013	file creation

function! ingo#collections#rotate#Right( list )
    return insert(a:list, remove(a:list, -1))
endfunction
function! ingo#collections#rotate#Left( list )
    return add(a:list, remove(a:list, 0))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
