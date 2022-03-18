" ingo/range/merge.vim: Functions for merging ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#range#merge#Merge( ranges )
"******************************************************************************
"* PURPOSE:
"   Merge adjacent and overlapping ranges.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:ranges    List of [start, end] pairs.
"* RETURN VALUES:
"   List of joined, non-overlapping [start, end] pairs in ascending order.
"******************************************************************************
    let l:dict = {}
    for [l:start, l:end] in a:ranges
	for l:i in range(l:start, l:end)
	    let l:dict[l:i] = 1
	endfor
    endfor

    return ingo#range#merge#FromLnums(l:dict)
endfunction

function! ingo#range#merge#FromLnums( lnumsCollection )
"******************************************************************************
"* PURPOSE:
"   Turn the collection of line numbers into a List of ranges.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnumsCollection   Either Dictionary where each key represents a line
"			number, or List (not necessarily unique or sorted) of
"			line numbers.
"* RETURN VALUES:
"   List of joined, non-overlapping [start, end] pairs in ascending order.
"******************************************************************************
    let l:lnums = (type(a:lnumsCollection) == type({}) ?
    \   sort(keys(a:lnumsCollection), 'ingo#collections#numsort') :
    \   ingo#collections#UniqueSorted(sort(a:lnumsCollection, 'ingo#collections#numsort'))
    \)

    let l:result = []
    while ! empty(l:lnums)
	let l:start = str2nr(remove(l:lnums, 0))
	let l:candidate = l:start + 1
	while ! empty(l:lnums) && str2nr(l:lnums[0]) == l:candidate
	    call remove(l:lnums, 0)
	    let l:candidate += 1
	endwhile

	call add(l:result, [l:start, l:candidate - 1])
    endwhile

    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
