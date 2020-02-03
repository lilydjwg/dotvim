" ingo/format.vim: Functions for printf()-like formatting of data.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.003	14-Apr-2017	Add ingo#format#Dict() variant of
"				ingo#format#Format() that only handles
"				identifier placeholders and a Dict containing
"				them.
"				ENH: ingo#format#Format(): Also handle a:fmt
"				without any "%" items without error.
"   1.029.002	23-Jan-2017	FIX: ingo#format#Format(): An invalid %0$
"				references the last passed argument instead of
"				yielding the empty string (as [argument-index$]
"				is 1-based). Add bounds check to avoid that
"				get() references index of -1.
"  				FIX: ingo#format#Format(): Also support escaping
"  				via "%%", as in printf().
"   1.015.001	18-Nov-2013	file creation

function! ingo#format#Format( fmt, ... )
"******************************************************************************
"* PURPOSE:
"   Return a String with a:fmt, where "%" items are replaced by the formatted
"   form of their respective arguments. Like |printf()|, but like Java's
"   String.format(), additionally supports explicit positioning with (1-based)
"   %[argument-index$], e.g. "The %2$s is %1$d".
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
    let l:printfFormat = substitute(a:fmt, '%\@<!%\%(\(\d\+\)\$\|[^%]\)', '\=s:ProcessFormat(a:000, l:args, submatch(1))', 'g')
    return (empty(l:args) ? l:printfFormat : call('printf', [l:printfFormat] + l:args))
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
	let l:indexedArg = (a:argCnt > 0 ? get(a:originalArgs, (a:argCnt - 1), '') : '')
	call add(a:args, l:indexedArg)
	return '%'
    endif
endfunction

function! ingo#format#Dict( fmt, dict )
"******************************************************************************
"* PURPOSE:
"   Return a String with a:fmt, where "%identifier$" items are replaced by the
"   formatted form of their respective arguments, e.g. "The %key$s" is
"   %value$d".
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:fmt   printf()-like format string.
"	    %  identifier $  [flags]  [field-width]  [.precision]  type
"   a:dict  Dictionary containing the identifiers referenced by the format
"   specifiers in the format string as keys; their corresponding values are then
"   used for the replacement.
"* RETURN VALUES:
"   Formatted string.
"******************************************************************************
    let l:args = []
    let l:printfFormat = substitute(a:fmt, '%\@<!%\(\w\+\)\$', '\=s:ProcessIdentifier(a:dict, l:args, submatch(1))', 'g')
    return (empty(l:args) ? l:printfFormat : call('printf', [l:printfFormat] + l:args))
endfunction
function! s:ProcessIdentifier( dict, args, identifier )
    call add(a:args, get(a:dict, a:identifier, ''))
    return '%'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
