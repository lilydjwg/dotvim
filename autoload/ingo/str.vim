" ingo/str.vim: String functions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.004	21-May-2014	Allow optional a:ignorecase argument for
"				ingo#str#StartsWith() and ingo#str#EndsWith().
"				Add ingo#str#Equals() for when it's convenient
"				to pass in the a:ignorecase flag. This avoids
"				coding the conditional between ==# and ==?
"				yourself.
"   1.016.003	23-Dec-2013	Add ingo#str#StartsWith() and
"				ingo#str#EndsWith().
"   1.011.002	26-Jul-2013	Add ingo#str#Reverse().
"   1.009.001	19-Jun-2013	file creation

function! ingo#str#Trim( string )
"******************************************************************************
"* PURPOSE:
"   Remove all leading and trailing whitespace from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"* RETURN VALUES:
"   a:string with leading and trailing whitespace removed.
"******************************************************************************
    return substitute(a:string, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

function! ingo#str#Reverse( string )
    return join(reverse(split(a:string, '\zs')), '')
endfunction

function! ingo#str#StartsWith( string, substring, ... )
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (strpart(a:string, 0, len(a:substring)) ==? a:substring)
    else
	return (strpart(a:string, 0, len(a:substring)) ==# a:substring)
    endif
endfunction
function! ingo#str#EndsWith( string, substring, ... )
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (strpart(a:string, len(a:string) - len(a:substring)) ==? a:substring)
    else
	return (strpart(a:string, len(a:string) - len(a:substring)) ==# a:substring)
    endif
endfunction

function! ingo#str#Equals( string1, string2, ...)
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return a:string1 ==? a:string2
    else
	return a:string1 ==# a:string2
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
