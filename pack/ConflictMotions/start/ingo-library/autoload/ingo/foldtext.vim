" ingo/foldtext.vim: Functions for creating a custom foldtext.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.001	19-Sep-2013	file creation

function! ingo#foldtext#DefaultPrefix( text )
    let l:num = v:foldend - v:foldstart + 1
    return printf("+-%s %2d line%s%s%s", v:folddashes, l:num, (l:num == 1 ? '' : 's'), (empty(a:text) ? '' : ': '), a:text)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
