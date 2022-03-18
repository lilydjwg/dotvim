" find.vim: Functions for finding indices in Lists.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	21-Oct-2016	file creation

function! ingo#list#find#FirstIndex( list, Filter )
"******************************************************************************
"* PURPOSE:
"   Find the first index of an item in a:list where a:filter is true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be searched.
"   a:Filter    Expression to be evaluated; v:val has the value of the current
"		item. Returns false to skip the item.
"		If a:Filter is a Funcref it is called with the value of the
"		current item.
"* RETURN VALUES:
"   First found index, or -1.
"******************************************************************************
    let l:idx = 0
    while l:idx < len(a:list)
	if ingo#actions#EvaluateWithValOrFunc(a:Filter, a:list[l:idx])
	    return l:idx
	endif
	let l:idx += 1
    endwhile
    return -1
endfunction

function! ingo#list#find#Indices( list, Filter )
"******************************************************************************
"* PURPOSE:
"   Find all indices of items in a:list where a:filter is true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be searched.
"   a:Filter    Expression to be evaluated; v:val has the value of the current
"		item. Returns false to skip the item.
"		If a:Filter is a Funcref it is called with the value of the
"		current item.
"* RETURN VALUES:
"   List of found indices, or empty List.
"******************************************************************************
    let l:indices = []
    let l:idx = 0
    while l:idx < len(a:list)
	if ingo#actions#EvaluateWithValOrFunc(a:Filter, a:list[l:idx])
	    call add(l:indices, l:idx)
	endif
	let l:idx += 1
    endwhile
    return l:indices
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
