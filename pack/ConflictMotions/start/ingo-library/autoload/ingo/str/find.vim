" ingo/str/find.vim: Functions to find stuff in a string.
"
" DEPENDENCIES:
"   - ingo/str.vim autoload script
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	14-Dec-2016	file creation

function! ingo#str#find#NotContaining( string, characterSet )
"******************************************************************************
"* PURPOSE:
"   Find the first character of a:characterSet not contained in a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Source string to be inspected.
"   a:characterSet  String or List of candidate characters.
"* RETURN VALUES:
"   First character in a:characterSet that is not contained in a:string, or
"   empty string if all characters are contained.
"******************************************************************************
    for l:candidate in (type(a:characterSet) == type([]) ? a:characterSet : split(a:characterSet, '\zs'))
	if stridx(a:string, l:candidate) == -1
	    return l:candidate
	endif
    endfor
    return ''
endfunction

function! ingo#str#find#StartIndex( haystack, needle, ... )
"******************************************************************************
"* PURPOSE:
"   Find the byte index in a:haystack of the first occurrence of a:needle
"   (starting the search at a:options.start, with a:options.ignorecase),
"   reducing a:needle's size from the end (until a:options.minMatchLength) to
"   fit what's left of a:haystack.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:haystack  String to be searched.
"   a:needle    String that is searched for. Characters are cut off at the end
"		if the search is farther down a:haystack so that the entire
"		a:needle wouldn't fit into it any longer.
"   a:options.minMatchLength    Minimum length of a:needle that must still match
"				in a:haystack; default is 1.
"   a:options.index             Index at which searching starts in a:haystack.
"   a:options.ignorecase        Flag whether searching is case-insensitive.
"* RETURN VALUES:
"   Byte index in a:haystack where (the remainder of) a:needle matches, or -1.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:minMatchLength = get(l:options, 'minMatchLength', 1)
    let l:index = get(l:options, 'index', 0)
    let l:ignorecase = get(l:options, 'ignorecase', 0)

    while l:index + l:minMatchLength <= len(a:haystack)
	let l:straw = strpart(a:haystack, l:index)
	if ingo#str#StartsWith(l:straw, strpart(a:needle, 0, len(l:straw)), l:ignorecase)
	    return l:index
	endif

	let l:index += len(matchstr(l:straw, '^.'))
    endwhile

    return -1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
