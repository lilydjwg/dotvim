" ingo/list/sequence.vim: Functions for sequences of numbers etc.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:NotRightType()
    throw 'NotRightType'
endfunction
function! s:ToNumber( val )
    return (type(a:val) == type(0) ? a:val : (a:val =~# '^\d\+$' ? str2nr(a:val) : s:NotRightType()))
endfunction
function! ingo#list#sequence#FindNumerical( list )
"******************************************************************************
"* PURPOSE:
"   Analyze whether a:list is made up / starts with a sequence of numbers, and return the
"   length of the sequence and stride.
"* ASSUMPTIONS / PRECONDITIONS:
"   All list elements are interpreted by their numerical value.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  Source list to be analyzed.
"* RETURN VALUES:
"   [sequenceLen, stride] (or [0, 0] if not at least two elements).
"******************************************************************************
    if len(a:list) < 2
	return [0, 0]
    endif

    let [l:idx, l:stride] = [0, 0]
    try
	let l:stride = s:ToNumber(a:list[1]) - s:ToNumber(a:list[0])

	let l:idx = 2
	while (l:idx < len(a:list) && s:ToNumber(a:list[l:idx]) - s:ToNumber(a:list[l:idx - 1]) == l:stride)
	    let l:idx += 1
	endwhile
    catch /NotRightType/
	" Using exception for flow control here.
    endtry
    return [l:idx, l:stride]
endfunction

function! ingo#list#sequence#FindCharacter( list )
"******************************************************************************
"* PURPOSE:
"   Analyze whether a:list is made up / starts with a sequence of single
"   characters, and return the length of the sequence and stride.
"* ASSUMPTIONS / PRECONDITIONS:
"   All list elements are interpreted as String.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  Source list to be analyzed.
"* RETURN VALUES:
"   [sequenceLen, stride] (or [0, 0] if not at least two elements, or not all
"   elements are single characters).
"******************************************************************************
    try
	let l:characterList = map(copy(a:list), 'v:val =~# "^.$" ? char2nr(v:val) : s:NotRightType()')
	return ingo#list#sequence#FindNumerical(l:characterList)
    catch /NotRightType/
	return [0, 0]
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
