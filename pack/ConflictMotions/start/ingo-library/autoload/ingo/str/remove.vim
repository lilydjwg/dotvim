" ingo/str/remove.vim: Functions to remove parts of a string.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#str#remove#Leading( string, prefix, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Remove leading literal a:prefix from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"   a:prefix    Text to be removed.
"   a:errorStrategy
"               What to do if a:string does not start with a:prefix:
"               "ignore":   Do not remove anything. This is the default.
"               "nocheck":  Simply remove the amount of bytes without checking.
"               "throw":    Throw 'Leading: {string} does not end with {prefix}'
"* RETURN VALUES:
"   a:string with leading a:prefix removed.
"******************************************************************************
    let l:errorStrategy = (a:0 ? a:1 : 'ignore')

    let l:prefixLen = len(a:prefix)

    if l:errorStrategy !=# 'nocheck'
	if strpart(a:string, 0, l:prefixLen) !=# a:prefix
	    if l:errorStrategy ==# 'throw'
		throw printf('Leading: "%s" does not start with "%s"', a:string, a:prefix)
	    elseif l:errorStrategy ==# 'ignore'
		return a:string
	    else
		throw 'ASSERT: Invalid errorStrategy: ' . l:errorStrategy
	    endif
	endif
    endif

    return strpart(a:string, l:prefixLen)
endfunction

function! ingo#str#remove#Trailing( string, suffix, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Remove trailing literal a:suffix from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"   a:suffix    Text to be removed.
"   a:errorStrategy
"               What to do if a:string does not end with a:suffix:
"               "ignore":   Do not remove anything. This is the default.
"               "nocheck":  Simply remove the amount of bytes without checking.
"               "throw":    Throw 'Trailing: {string} does not end with {suffix}'
"* RETURN VALUES:
"   a:string with trailing a:suffix removed.
"******************************************************************************
    let l:errorStrategy = (a:0 ? a:1 : 'ignore')

    let l:offset = len(a:string) - len(a:suffix)

    if l:errorStrategy !=# 'nocheck'
	if l:offset < 0 || strpart(a:string, l:offset) !=# a:suffix
	    if l:errorStrategy ==# 'throw'
		throw printf('Trailing: "%s" does not end with "%s"', a:string, a:suffix)
	    elseif l:errorStrategy ==# 'ignore'
		return a:string
	    else
		throw 'ASSERT: Invalid errorStrategy: ' . l:errorStrategy
	    endif
	endif
    endif

    return strpart(a:string, 0, l:offset)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
