" ingo/format.vim: Functions for printf()-like formatting of data.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.015.001	18-Nov-2013	file creation

function! ingo#format#Format( fmt, ... )
"******************************************************************************
"* PURPOSE:
"   Return a String with a:fmt, where "%" items are replaced by the formatted
"   form of their respective arguments. Like |printf()|, but like Java's
"   String.format(), additionally supports explicit positioning with
"   %[argument-index$].
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:fmt   printf()-like format string.
"	    %  [argument-index$]  [flags]  [field-width]  [.precision]  type
"   a:args  Arguments referenced by the format specifiers in the format string.
"	    If there are more arguments than format specifiers, the extra
"	    arguments are ignored (unlike printf()!). The number of arguments is
"	    variable and may be zero.
"* RETURN VALUES:
"   Formatted string.
"******************************************************************************
    let l:args = []
    let s:consumedOriginalArgIdx = -1
    let l:printfFormat = substitute(a:fmt, '%\%(\(\d\+\)\$\|.\)', '\=s:ProcessFormat(a:000, l:args, submatch(1))', 'g')
    return call('printf', [l:printfFormat] + l:args)
endfunction
function! s:ProcessFormat( originalArgs, args, argCnt )
    if empty(a:argCnt)
	" Consume an original argument, or supply an empty arg.
	" Note: This will fail for %f with "E807: Expected Float argument for
	" printf()".
	let s:consumedOriginalArgIdx += 1
	call add(a:args, get(a:originalArgs, s:consumedOriginalArgIdx, ''))
	return submatch(0)
    else
	" Copy the indexed argument.
	call add(a:args, get(a:originalArgs, (a:argCnt - 1), ''))
	return '%'
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
