" ingo/list/split.vim: Functions for splitting Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#list#split#ChunksOf( list, n, ... )
"******************************************************************************
"* PURPOSE:
"   Split a:list into a List of Lists of a:n elements.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Clears a:list.
"* INPUTS:
"   a:list  Source list.
"   a:n     Number of elements for each sublist.
"   a:fillValue Optional element that is used to fill the last sublist with if
"		there are not a:n elements left for it. If omitted, the last
"		sublist may have less than a:n elements.
"* RETURN VALUES:
"   [[e1, e2, ... en], [...]]
"******************************************************************************
    let l:result = []
    while ! empty(a:list)
	if len(a:list) >= a:n
	    let l:subList = remove(a:list, 0, a:n - 1)
	else
	    let l:subList = remove(a:list, 0, -1)
	    if a:0
		call extend(l:subList, repeat([a:1], a:n - len(l:subList)))
	    endif
	endif
	call add(l:result, l:subList)
    endwhile
    return l:result
endfunction

function! ingo#list#split#RemoveFromStartWhilePredicate( list, Predicate )
"******************************************************************************
"* PURPOSE:
"   Split off elements from the start of a:list while a:Predicate is true.
"* SEE ALSO:
"   - If you want to split off _all_ elements where a:Predicate matches (not
"     just from the start), use ingo#collections#Partition() instead.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Removes element(s) from the start of the list.
"* INPUTS:
"   a:list      Source list.
"   a:Predicate Either a Funcref or an expression to be eval()ed where v:val
"               represents the current element.
"* RETURN VALUES:
"   List of elements that matched a:Predicate at the start of a:list.
"******************************************************************************
    let l:idx = 0
    while l:idx < len(a:list) && ingo#actions#EvaluateWithValOrFunc(a:Predicate, a:list[l:idx])
	let l:idx += 1
    endwhile

    return (l:idx > 0 ? remove(a:list, 0, l:idx - 1) : [])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
