" ingo/subst.vim: Functions for substitutions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	14-Jun-2013	file creation

function! ingo#subst#gsub( expr, pat, sub )
    return substitute(a:expr, '\C' . a:pat, a:sub, 'g')
endfunction

function! ingo#subst#MultiGsub( expr, substitutions )
"******************************************************************************
"* PURPOSE:
"   Perform a set of global substitutions in-order on the same text.
"   Neither 'ignorecase' nor 'smartcase' nor 'magic' applies.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be transformed.
"   a:substitutions List of [pattern, substitution] tuples; is processed from
"		    begin to end.
"* RETURN VALUES:
"   Transformed a:expr.
"******************************************************************************
    let l:expr = a:expr
    for [l:pat, l:sub] in a:substitutions
	let l:expr = ingo#subst#gsub(l:expr, l:pat, l:sub)
    endfor
    return l:expr
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
