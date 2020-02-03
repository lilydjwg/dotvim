" ingo/list/pattern.vim: Functions for applying a regular expression to List items.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#list#pattern#AllItemsMatch( list, pattern )
"******************************************************************************
"* PURPOSE:
"   Test whether each item of the list matches the regular expression.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      A list.
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   1 if all items of a:list match a:pattern; else 0.
"******************************************************************************
    return empty(filter(copy(a:list), 'v:val !~# a:pattern'))
endfunction

function! ingo#list#pattern#FirstMatchIndex( list, pattern )
"******************************************************************************
"* PURPOSE:
"   Return the index of the first item in a:list that matches a:pattern, or -1.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      A list.
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   Index of the first item that matches a:pattern, or -1 if no item matches.
"******************************************************************************
    let l:i = 0
    while l:i < len(a:list)
	if a:list[l:i] =~# a:pattern
	    return l:i
	endif
	let l:i += 1
    endwhile
    return -1
endfunction

function! ingo#list#pattern#FirstMatch( list, pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Return the first item in a:list that matches a:pattern, or an empty String.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      A list.
"   a:pattern   Regular expression.
"   a:noMatchValue  Optional value that is returned (instead of an empty String)
"                   if a:pattern does not match at all.
"* RETURN VALUES:
"   First item that matches a:pattern, or '' (or a:noMatchValue).
"******************************************************************************
    let l:i = ingo#list#pattern#FirstMatchIndex(a:list, a:pattern)
    return (l:i == -1 ? (a:0 ? a:1 : '') : a:list[l:i])
endfunction

function! ingo#list#pattern#AllMatchIndices( list, pattern )
"******************************************************************************
"* PURPOSE:
"   Return a List of indices of those items in a:list that match a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      A list.
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   (Possibly empty) List of (ascending) indices of matching items.
"******************************************************************************
    let l:i = 0
    let l:result = []
    while l:i < len(a:list)
	if a:list[l:i] =~# a:pattern
	    call add(l:result, l:i)
	endif
	let l:i += 1
    endwhile
    return l:result
endfunction

function! ingo#list#pattern#AllMatches( list, pattern )
"******************************************************************************
"* PURPOSE:
"   Return a List of those items in a:list that match a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      A list.
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   (Possibly empty) List of matching items. The original a:list is left
"   untouched.
"******************************************************************************
    let l:i = 0
    let l:result = []
    while l:i < len(a:list)
	if a:list[l:i] =~# a:pattern
	    call add(l:result, a:list[l:i])
	endif
	let l:i += 1
    endwhile
    return l:result
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
