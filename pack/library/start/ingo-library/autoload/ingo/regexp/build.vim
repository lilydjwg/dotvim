" ingo/regexp/build.vim: Functions to build regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#build#Prepend( target, fragment )
"******************************************************************************
"* PURPOSE:
"   Add a:fragment at the beginning of a:target, considering the anchor ^.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:target    Regular expression to manipulate.
"   a:fragment  Regular expression fragment to insert.
"* RETURN VALUES:
"   New regexp.
"******************************************************************************
    return substitute(a:target, '^\%(\\%\?(\)*^\?', '&' . escape(a:fragment, '\&'), '')
endfunction

function! ingo#regexp#build#Append( target, fragment )
"******************************************************************************
"* PURPOSE:
"   Add a:fragment at the end of a:target, considering the anchor $.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:target    Regular expression to manipulate.
"   a:fragment  Regular expression fragment to insert.
"* RETURN VALUES:
"   New regexp.
"******************************************************************************
    return substitute(a:target, '$\?\%(\\)\)*$', escape(a:fragment, '\&') . '&', '')
endfunction

function! ingo#regexp#build#UnderCursor( pattern )
"******************************************************************************
"* PURPOSE:
"   Create a regular expression that only matches a:pattern when the cursor is
"   (somewhere) on the match. Stuff excluded by \zs / \ze still counts a match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   Augmented a:pattern that only matches when the cursor is on the match.
"******************************************************************************
    " Positive lookahead at the front to ensure that the cursor is at the start
    " of a:pattern or after that.
    " Positive lookbehind at the back to ensure that the cursor is before (not
    " at, that would already be one behind) the match.
    return '\%(.\{-}\%#\)\@=\%(' . a:pattern . '\m\)\%(\%#.\{-1,}\)\@<='
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
