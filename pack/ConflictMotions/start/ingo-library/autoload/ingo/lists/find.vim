" ingo/lists/find.vim: Functions for comparing Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#lists#find#FirstDifferent( list1, list2 )
"******************************************************************************
"* PURPOSE:
"   Compare elements in a:list1 and a:list2 and return the index of the first
"   elements that are not equal.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1 A list.
"   a:list2 Another list.
"* RETURN VALUES:
"   Index of the first element not equal / not existing in one of the lists.
"   -1 if both lists are identical; i.e. have the same number of elements and
"   all elements are equal..
"******************************************************************************
    let l:i = 0
    while l:i < len(a:list1)
	if l:i >= len(a:list2)
	    return l:i
	elseif a:list1[l:i] != a:list2[l:i]
	    return l:i
	endif

	let l:i += 1
    endwhile
    return -1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
