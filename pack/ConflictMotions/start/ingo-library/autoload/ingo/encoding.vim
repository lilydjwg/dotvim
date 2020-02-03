" ingo/encoding.vim: Functions for dealing with character encodings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.001	20-Feb-2015	file creation

function! ingo#encoding#GetFileEncoding()
    return (empty(&l:fileencoding) ? &encoding : &l:fileencoding)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
