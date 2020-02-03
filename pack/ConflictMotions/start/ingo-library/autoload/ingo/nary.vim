" ingo/nary.vim: Functions for working with tuples of numbers in a fixed range.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.001	14-May-2017	file creation

function! ingo#nary#FromNumber( n, number, ... )
"******************************************************************************
"* PURPOSE:
"   Turn the integer a:number into a (little-endian) List of values from [0..n).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:n         Maximum number that can be represented by one List element.
"   a:number    Positive integer.
"   a:elementNum    Optional number of elements to use. If specified and
"		    a:number cannot be represented by it, a exception is thrown.
"		    If a:elementNum is negative, only the lower elements will be
"		    returned. If omitted, the minimal amount of elements is
"		    used.
"* RETURN VALUES:
"   List of [e0, e1, e2, ...] values; lowest come first.
"******************************************************************************
    let l:number = a:number
    let l:result = []
    let l:elementCnt = 0
    let l:elementMax = (a:0 ? ingo#compat#abs(a:1) : 0)

    while 1
	" Encode this little-endian.
	call add(l:result, l:number % a:n)
	let l:number = l:number / a:n
	let l:elementCnt += 1

	if l:elementMax && l:elementCnt == l:elementMax
	    if a:1 > 0 && l:number != 0
		throw printf('FromNumber: Cannot represent %d in %d elements', a:number, l:elementMax)
	    endif
	    break
	elseif ! a:0 && l:number == 0
	    break
	endif
    endwhile
    return l:result
endfunction
function! ingo#nary#ToNumber( n, elements )
"******************************************************************************
"* PURPOSE:
"   Turn the (little-endian) List of boolean values from [0..n) into a number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:n         Maximum number that can be represented by one List element.
"   a:elements  List of [e0, e1, e2, ...] values; lowest elements come first.
"* RETURN VALUES:
"   Positive integer represented by a:elements.
"******************************************************************************
    let l:number = 0
    let l:factor = 1
    while ! empty(a:elements)
	let l:number += l:factor * remove(a:elements, 0)
	let l:factor = l:factor * a:n
    endwhile
    return l:number
endfunction

function! ingo#nary#ElementsRequired( n, number )
"******************************************************************************
"* PURPOSE:
"   Determine the number of elements within [0..n) required to represent a:number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:n         Maximum number that can be represented by one List element.
"   a:number    Positive integer.
"* RETURN VALUES:
"   Number of elements required to represent numbers between 0 and a:number.
"******************************************************************************
    let l:elementCnt = 1
    let l:max = a:n
    while a:number >= l:max
	let l:elementCnt += 1
	let l:max = l:max * a:n
    endwhile
    return l:elementCnt
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
