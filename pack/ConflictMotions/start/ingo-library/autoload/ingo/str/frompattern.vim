" ingo/str/frompattern.vim: Functions to get matches from a string.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.001	30-Dec-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#str#frompattern#Get( text, pattern, replacement, isOnlyFirstMatch, isUnique )
"******************************************************************************
"* PURPOSE:
"   Extract all non-overlapping matches of a:pattern in a:text and return them
"   (optionally a submatch / replacement, or only first or unique matches) as a
"   List.
"* SEE ALSO:
"   - ingo#text#frompattern#Get() extracts matches directly from a range of
"     lines.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text          Source text, either a String (potentially with newlines), or
"		    a List of lines.
"   a:pattern       Regular expression to search. 'ignorecase' applies;
"		    'smartcase' and 'magic' don't. When empty, the last search
"		    pattern |"/| is used.
"   a:replacement   Optional replacement substitute(). When not empty, each
"		    match is processed through substitute() with a:pattern.
"		    You can also pass a [replPattern, replacement] tuple, which
"		    will then be globally applied to the match.
"   a:isOnlyFirstMatch  Flag whether to include only the first match in every
"			line.
"   a:isUnique          Flag whether duplicate matches are omitted from the
"			result. When set, the result will consist of unique
"			matches.
"* RETURN VALUES:
"   List of (optionally replaced) matches, or empty List when no matches.
"******************************************************************************
    let l:matches = []
    let l:pattern = (empty(a:pattern) ? @/ : a:pattern)

    if a:isOnlyFirstMatch
	" Need to process each line separately to only extract first matches.
	let l:source = (type(a:text) == type([]) ? a:text : split(a:text, '\n', 1))
	call map(
	\   l:source,
	\   'substitute(v:val, l:pattern, "\\=s:Collect(l:matches, a:isUnique)", "")'
	\)
    else
	let l:source = (type(a:text) == type([]) ? join(a:text, "\n") : a:text)
	call substitute(l:source, l:pattern, '\=s:Collect(l:matches, a:isUnique)', 'g')
    endif

    if ! empty(a:replacement)
	call map(
	\   l:matches,
	\   'type(a:replacement) == type([]) ?' .
	\       'substitute(v:val, a:replacement[0], a:replacement[1], "g") :' .
	\       'substitute(v:val, l:pattern, a:replacement, "")'
	\)

	if a:isUnique
	    " The replacement may have mapped different matches to the same
	    " replacement; need to restore the uniqueness.
	    let l:matches = ingo#collections#UniqueStable(l:matches)
	endif
    endif

    return l:matches
endfunction
function! s:Collect( accumulatorMatches, isUnique )
    let l:match = submatch(0)
	if ! a:isUnique || index(a:accumulatorMatches, l:match) == -1
	    call add(a:accumulatorMatches, l:match)
	endif
    return l:match
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
