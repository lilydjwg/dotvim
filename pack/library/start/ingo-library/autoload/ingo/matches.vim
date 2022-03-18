" ingo/matches.vim: Functions for pattern matching.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:Count()
    let s:matchCnt += 1
    return submatch(0)
endfunction
function! ingo#matches#CountMatches( text, pattern )
"******************************************************************************
"* PURPOSE:
"   Count the number of matches of a:pattern in a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  String or List of Strings to be matches (each element individually).
"   a:pattern   Regular expression to be matched.
"* RETURN VALUES:
"   Number of matches.
"******************************************************************************
    let s:matchCnt = 0
    for l:line in ingo#list#Make(a:text)
	call substitute(l:line, a:pattern, '\=s:Count()', 'g')
    endfor
    return s:matchCnt
endfunction


function! ingo#matches#Any( text, patterns )
"******************************************************************************
"* PURPOSE:
"   Test whether any pattern in a:pattern matches a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  String to be tested.
"   a:patterns  List of regular expressions.
"* RETURN VALUES:
"   1 if at least one pattern in a:patterns matches in a:text (or no pattern was
"   passed); 0 otherwise.
"******************************************************************************
    for l:pattern in a:patterns
	if a:text =~# l:pattern
	    return 1
	endif
    endfor
    return empty(a:patterns)
endfunction
function! ingo#matches#All( text, patterns )
"******************************************************************************
"* PURPOSE:
"   Test whether all patterns in a:pattern matches a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  String to be tested.
"   a:patterns  List of regular expressions.
"* RETURN VALUES:
"   0 if at least one pattern in a:patterns does not match a:text; 1 otherwise.
"******************************************************************************
    for l:pattern in a:patterns
	if a:text !~# l:pattern
	    return 0
	endif
    endfor
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
