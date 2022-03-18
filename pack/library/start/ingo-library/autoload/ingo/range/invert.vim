" ingo/range/invert.vim: Functions for inverting ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	21-Dec-2016	file creation

function! ingo#range#invert#Invert( startLnum, endLnum, ranges )
"******************************************************************************
"* PURPOSE:
"   Invert the ranges in a:ranges. Lines within a:startLnum, a:endLnum that were
"   contained in the ranges will be out, and all other lines will be in.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startLnum First line number to be considered.
"   a:endLnum   Last line number to be considered.
"   a:ranges    List of [start, end] pairs in ascending, non-overlapping order.
"		Invoke ingo#range#merge#Merge() first if necessary.
"* RETURN VALUES:
"   List of [start, end] pairs in ascending order.
"******************************************************************************
    let l:result = []

    let l:lastIncludedLnum = a:startLnum - 1
    for [l:fromLnum, l:toLnum] in a:ranges
	call s:Add(l:result, a:startLnum, a:endLnum, l:lastIncludedLnum + 1, l:fromLnum - 1)
	let l:lastIncludedLnum = l:toLnum
    endfor
    call s:Add(l:result, a:startLnum, a:endLnum, l:lastIncludedLnum + 1, a:endLnum)
    return l:result
endfunction
function! s:Add( target, startLnum, endLnum, fromLnum, toLnum )
    let l:fromLnum = max([a:startLnum, a:fromLnum])
    let l:toLnum = min([a:endLnum, a:toLnum])

    if l:fromLnum > l:toLnum
	return
    endif
    call add(a:target, [l:fromLnum, l:toLnum])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
