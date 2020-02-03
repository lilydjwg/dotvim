" ingo/collections/unique.vim: Functions to create and operate on unique collections.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.003	17-Feb-2016	Add ingo#collections#unique#Insert() and
"				ingo#collections#unique#Add().
"   1.010.002	03-Jul-2013	Add ingo#collections#unique#AddNew() and
"				ingo#collections#unique#InsertNew().
"   1.009.001	25-Jun-2013	file creation

function! ingo#collections#unique#MakeUnique( memory, expr )
"******************************************************************************
"* PURPOSE:
"   Based on the a:memory lookup, create a unique String from a:expr by
"   appending a running counter to it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Adds the unique returned result to a:memory.
"* INPUTS:
"   a:memory    Dictionary holding the existing values as keys.
"   a:expr      String that is made unique with regards to a:memory and
"		returned.
"* RETURN VALUES:
"   a:expr (when it's not yet contained in the a:memory), or a unique version of
"   it.
"******************************************************************************
    let l:result = a:expr
    let l:counter = 0
    while has_key(a:memory, l:result)
	let l:counter += 1
	let l:result = printf('%s%s(%d)', a:expr, (empty(a:expr) ? '' : ' '), l:counter)
    endwhile

    let a:memory[l:result] = 1
    return l:result
endfunction

function! ingo#collections#unique#AddNew( list, expr )
"******************************************************************************
"* PURPOSE:
"   Append a:expr to a:list when it's not already contained.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be modified.
"   a:expr  Item to be added.
"* RETURN VALUES:
"   a:list
"******************************************************************************
    return ingo#collections#unique#InsertNew(a:list, a:expr, len(a:list))
endfunction
function! ingo#collections#unique#InsertNew( list, expr, ... )
"******************************************************************************
"* PURPOSE:
"   Insert a:expr at the start of a:list when it's not already contained.
"   If a:idx is specified insert a:expr before the item with index a:idx.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be modified.
"   a:expr  Item to be added.
"   a:idx   Optional index before which a:expr is inserted.
"* RETURN VALUES:
"   a:list
"******************************************************************************
    if index(a:list, a:expr) == -1
	return call('insert', [a:list, a:expr] + a:000)
    else
	return a:list
    endif
endfunction

function! ingo#collections#unique#ExtendWithNew( expr1, expr2, ... )
"******************************************************************************
"* PURPOSE:
"   Append all items from a:expr2 that are not yet contained in a:expr1 to it.
"   If a:expr3 is given insert the items of a:expr2 before item a:expr3 in
"   a:expr1. When a:expr3 is zero insert before the first item.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"* RETURN VALUES:
"   Returns the modified a:expr1.
"******************************************************************************
    let l:newItems = filter(copy(a:expr2), 'index(a:expr1, v:val) == -1')
    return call('extend', [a:expr1, l:newItems] + a:000)
endfunction

function! ingo#collections#unique#Insert( list, expr, ... )
"******************************************************************************
"* PURPOSE:
"   Insert a:expr at the start of a:list (if a:idx is specified before the item
"   with index a:idx), and remove any other elements equal to a:expr from the
"   list (which effectively moves a:expr to the front).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be modified.
"   a:expr  Item to be added.
"   a:idx   Optional index before which a:expr is inserted.
"* RETURN VALUES:
"   a:list
"******************************************************************************
    call filter(a:list, 'v:val isnot# a:expr')
    return call('insert', [a:list, a:expr] + a:000)
endfunction
function! ingo#collections#unique#Add( list, expr )
"******************************************************************************
"* PURPOSE:
"   Append a:expr to a:list, and remove any other elements equal to a:expr from
"   the list (which effectively moves a:expr to the back).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be modified.
"   a:expr  Item to be added.
"* RETURN VALUES:
"   a:list
"******************************************************************************
    call filter(a:list, 'v:val isnot# a:expr')
    return add(a:list, a:expr)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
