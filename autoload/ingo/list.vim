" ingo/list.vim: Functions to operate on Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.001	15-Oct-2013	file creation

function! ingo#list#Make( val, ... )
"******************************************************************************
"* PURPOSE:
"   Ensure that the passed a:val is a List; if not, wrap it in one.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:val   Arbitrary value of arbitrary type.
"   a:isCopyOriginalList    Optional flag; when set, an original a:val List is
"			    copied before returning.
"* RETURN VALUES:
"   List; either the original one or a new one containing a:val.
"******************************************************************************
    return (type(a:val) == type([]) ? (a:0 && a:1 ? copy(a:val) : a:val) : [a:val])
endfunction

function! ingo#list#AddOrExtend( list, val, ... )
"******************************************************************************
"* PURPOSE:
"   Add a:val as element(s) to a:list. Extends a List, adds other types.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be extended.
"   a:val   Arbitrary value of arbitrary type.
"   a:idx   Optional index before where in a:list to insert. Default to
"	    appending.
"* RETURN VALUES:
"   Returns the resulting a:list.
"******************************************************************************
    if type(a:val) == type([])
	if a:0
	    call extend(a:list, a:val, a:1)
	else
	    call extend(a:list, a:val)
	endif
    else
	if a:0
	    call insert(a:list, a:val, a:1)
	else
	    call add(a:list, a:val)
	endif
    endif
    return a:list
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
