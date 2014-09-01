" ingo/str/split.vim: Functions for splitting strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	27-Jun-2013	file creation

function! ingo#str#split#First( expr, pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:expr into the text before and after the first match of a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be split.
"   a:pattern	The pattern to split on; 'ignorecase' applies.
"* RETURN VALUES:
"   Tuple of [beforeMatch, matchedText, afterMatch].
"   When there's no match of a:pattern, the returned tuple is [a:expr, '', ''].
"******************************************************************************
    let l:startIdx = match(a:expr, a:pattern)
    if l:startIdx == -1
	return [a:expr, '', '']
    endif

    let l:endIdx = matchend(a:expr, a:pattern)
    return [strpart(a:expr, 0, l:startIdx), strpart(a:expr, l:startIdx, l:endIdx - l:startIdx), strpart(a:expr, l:endIdx)]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
