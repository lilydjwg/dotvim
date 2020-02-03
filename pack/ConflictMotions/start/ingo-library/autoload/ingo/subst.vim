" ingo/subst.vim: Functions for substitutions.
"
" DEPENDENCIES:
"   - ingo/format.vim autoload script
"   - ingo/subst/replacement.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

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

function! ingo#subst#FirstSubstitution( expr, flags, ... )
"******************************************************************************
"* PURPOSE:
"   Perform a substitution with the first matching [a:pattern, a:replacement]
"   substitution.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be transformed.
"   [a:pattern0, a:replacement0], ...   List of [pattern, substitution] tuples.
"* RETURN VALUES:
"   [patternIndex, replacement]; if no supplied pattern matched, returns
"   [-1, a:expr].
"******************************************************************************
    for l:patternIndex in range(len(a:000))
	let [l:pattern, l:replacement] = a:000[l:patternIndex]
	if a:expr =~ l:pattern
	    return [l:patternIndex, substitute(a:expr, l:pattern, l:replacement, a:flags)]
	endif
    endfor
    return [-1, a:expr]
endfunction

function! ingo#subst#FirstPattern( expr, replacement, flags, ... )
"******************************************************************************
"* PURPOSE:
"   Perform a substitution with the first matching a:pattern0, a:pattern1, ...
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be transformed.
"   a:replacement   Replacement (applied regardless of the chosen a:patternX)
"   a:pattern0, ... Search patterns.
"* RETURN VALUES:
"   [patternIndex, replacement]; if no supplied pattern matched, returns
"   [-1, a:expr].
"******************************************************************************
    for l:patternIndex in range(len(a:000))
	let l:pattern = a:000[l:patternIndex]
	if a:expr =~ l:pattern
	    return [l:patternIndex, substitute(a:expr, l:pattern, a:replacement, a:flags)]
	endif
    endfor
    return [-1, a:expr]
endfunction

function! ingo#subst#FirstParameter( expr, patternTemplate, replacement, flags, ... )
"******************************************************************************
"* PURPOSE:
"   Insert a:parameter1, ... into a:patternTemplate and perform a substitution
"   with the first matching resulting pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be transformed.
"   a:patternTemplate   Regular expression template; parameters are inserted
"			into the %s (or named %[argument-index]$s) inside the
"			template.
"   a:replacement       Replacement.
"   a:parameter1, ...   Parameters (regexp fragments) to be inserted into
"			a:patternTemplate.
"* RETURN VALUES:
"   [patternIndex, replacement]; if no supplied pattern matched, returns
"   [-1, a:expr].
"******************************************************************************
    let l:isIndexedParameter = (a:patternTemplate =~# '%\@<!%\d\+\$s')
    for l:patternIndex in range(len(a:000))
	let l:parameter = a:000[l:patternIndex]

	let l:currentParameterArgs = (l:isIndexedParameter ?
	\   repeat([''], l:patternIndex) + [l:parameter] :
	\   [l:parameter]
	\)
	let l:pattern = call('ingo#format#Format', [a:patternTemplate] + l:currentParameterArgs)

	if a:expr =~ l:pattern
	    return [l:patternIndex, substitute(a:expr, l:pattern, a:replacement, a:flags)]
	endif
    endfor
    return [-1, a:expr]
endfunction

function! ingo#subst#Indexed( expr, pattern, replacement, indices, ... )
"******************************************************************************
"* PURPOSE:
"   Substitute only / not the N+1'th matches for the N in a:indices. Other
"   matches are kept as-is.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be transformed.
"   a:pattern   Regular expression.
"   a:replacement       Replacement. Handles |sub-replace-expression|, & and \0,
"                       \1 .. \9, and \r\n\t\b (but not \u, \U, etc.)
"   a:indices   List of 0-based indices whose corresponding matches are
"               replaced. A String value of "g" replaces globally, just like
"               substitute(..., 'g').
"   a:isInvert  Flag whether only those matches whose indices are NOT in
"               a:indices are replaced. Does not invert the "g" String value.
"               Default is false.
"* RETURN VALUES:
"   Replacement.
"******************************************************************************
    if type(a:indices) == type('') && a:indices ==# 'g'
	return substitute(a:expr, a:pattern, a:replacement, 'g')
    endif

    let l:context = {
    \   'matchCnt': 0,
    \   'indices': a:indices,
    \   'isInvert': (a:0 ? a:1 : 0),
    \   'replacement': a:replacement
    \}
    return substitute(a:expr, a:pattern, '\=s:IndexReplacer(l:context)', 'g')
endfunction
function! s:IndexReplacer( context )
    let a:context.matchCnt += 1
    execute 'let l:isSelected = index(a:context.indices, a:context.matchCnt - 1)' (a:context.isInvert ? '==' : '!=') '-1'
    return ingo#subst#replacement#DefaultReplacementOnPredicate(l:isSelected, a:context)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
