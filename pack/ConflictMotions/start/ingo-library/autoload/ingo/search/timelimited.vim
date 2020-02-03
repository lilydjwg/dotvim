" ingo/search/timelimited.vim: Functions for time-limited searching.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.003.002	26-Mar-2013	Move to ingo-library.
"	001	17-Oct-2012	file creation

if v:version < 702 || ! has('reltime')
function! ingo#search#timelimited#GetSearchArguments( timeout )
    " Limit searching to a maximum number of lines after the cursor.
    " Assume that 10000 lines can be searched per second; this depends greatly
    " on the CPU, regexp, and line length.
    return [(a:timeout == 0 ? 0 : line('.') + a:timeout * 10)]
endfunction
else
function! ingo#search#timelimited#GetSearchArguments( timeout )
    return [0, a:timeout]
endfunction
endif

function! ingo#search#timelimited#search( pattern, flags, ... )
    let l:timeout = (a:0 ? a:1 : 100)
    return call('search', [a:pattern, a:flags] + ingo#search#timelimited#GetSearchArguments(l:timeout))
endfunction
function! ingo#search#timelimited#IsBufferContains( pattern, ... )
    return call('ingo#search#timelimited#search', [a:pattern, 'cnw'] + a:000)
endfunction
function! ingo#search#timelimited#FirstPatternThatMatchesInBuffer( patterns, ... )
"******************************************************************************
"* PURPOSE:
"   Search for matches of any of a:patterns in the buffer, and return the first
"   pattern that matches.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:patterns  List of regular expressions.
"   a:timeout   Optional timeout in milliseconds; default 100.
"* RETURN VALUES:
"   First pattern from a:patterns that matches somewhere in the current buffer,
"   or empty String.
"******************************************************************************
    for l:pattern in a:patterns
	if call('ingo#search#timelimited#search', [l:pattern, 'cnw'] + a:000)
	    return l:pattern
	endif
    endfor
    return ''
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
