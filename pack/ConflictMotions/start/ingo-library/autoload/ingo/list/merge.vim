" ingo/list/merge.vim: Functions for merging lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#list#merge#Distinct( ... ) abort
"******************************************************************************
"* PURPOSE:
"   From several Lists where there's only one non-empty value at each index
"   position, create a combined list taking that non-empty value from each index
"   position (or the empty value from the first list).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1, a:list2
"* RETURN VALUES:
"   Combined List with as many elements as the longest passed List.
"   Throws "Distinct: Multiple non-empty values at index N"
"******************************************************************************
    let l:result = []
    for l:i in range(max(map(copy(a:000), 'len(v:val)')))
	let l:nonEmptyIndexValues = filter(
	\   map(range(a:0), 'get(a:000[v:val], l:i, "")'),
	\   '! empty(v:val)'
	\)
	if len(l:nonEmptyIndexValues) > 1
	    throw 'Distinct: Multiple non-empty values at index ' . l:i
	endif
	call add(l:result, (empty(l:nonEmptyIndexValues) ?
	\   map(range(a:0), 'len(a:000[v:val]) >= l:i ? a:000[v:val][l:i] : ""')[0] :
	\   l:nonEmptyIndexValues[0]
	\))
    endfor
    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
