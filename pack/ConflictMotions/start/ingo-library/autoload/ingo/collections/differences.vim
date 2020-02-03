" ingo/collections/differences.vim: Functions to obtain the differences between lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.002	29-Jul-2016	Add
"				ingo#collections#differences#ContainsLoosely()
"				and
"				ingo#collections#differences#ContainsStrictly().
"   1.024.001	13-Feb-2015	file creation

function! s:GetMissing( list1, list2 )
    " Note: We assume there are far less differences than common elements, so we
    " don't copy() and filter() the original list, and instead iterate.
    let l:notIn2 = []
    for l:item in a:list1
	if index(a:list2, l:item) == -1
	    call add(l:notIn2, l:item)
	endif
    endfor
    return l:notIn2
endfunction
function! ingo#collections#differences#Get( list1, list2 )
"******************************************************************************
"* PURPOSE:
"   Determine the elements missing in the other list.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1 A list.
"   a:list2 A list.
"* RETURN VALUES:
"   Two lists: [ notIn2, notIn1 ] that contain the elements (in the same order)
"   not found in the other list. If the passed lists are equal, both are empty.
"******************************************************************************
    let l:notIn2 = s:GetMissing(a:list1, a:list2)
    let l:notIn1 = s:GetMissing(a:list2, a:list1)
    return [l:notIn2, l:notIn1]
endfunction

function! ingo#collections#differences#ContainsLoosely( list1, list2 )
"******************************************************************************
"* PURPOSE:
"   Test whether all elements in a:list2 are also contained in a:list1. Each
"   equal element need only be contained once.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1 A list that may contain all elements from a:list2.
"   a:list2 List where all elements may also be contained in a:list1.
"* RETURN VALUES:
"   1 if all elements from a:list2 are also contained in a:list1, 0 otherwise.
"******************************************************************************
    return empty(s:GetMissing(a:list2, a:list1))
endfunction
function! ingo#collections#differences#ContainsStrictly( list1, list2 )
"******************************************************************************
"* PURPOSE:
"   Test whether all elements in a:list2 are also contained in a:list1. Each
"   equal element must be contained at least as often.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1 A list that may contain all elements from a:list2.
"   a:list2 List where all elements may also be contained in a:list1.
"* RETURN VALUES:
"   1 if all elements from a:list2 are also contained in a:list1, 0 otherwise.
"******************************************************************************
    let l:copy = copy(a:list1)
    for l:item in a:list2
	let l:idx = index(l:copy, l:item)
	if l:idx == -1
	    return 0
	endif
	call remove(l:copy, l:idx)
    endfor
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
