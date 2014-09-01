" ingo/subst/expr/emulation.vim: Function to emulate sub-replace-expression for recursive use.
"
" DEPENDENCIES:
"   - ingo/collection.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.001	07-Mar-2014	file creation

function! s:Submatch( idx )
    return get(s:submatches, a:idx, '')
endfunction
function! s:EmulateSubmatch( originalExpr, expr, pat, sub )
    let s:submatches = matchlist(a:expr, a:pat)
	if empty(s:submatches)
	    let l:innerReplacement = a:originalExpr
	else
	    let l:innerReplacement = eval(a:sub)
	endif
    unlet s:submatches
    return l:innerReplacement
endfunction
function! ingo#subst#expr#emulation#Substitute( expr, pat, sub, flags )
    if a:sub =~# '^\\='
	" Recursive use of \= is not allowed, so we need to emulate it:
	" matchlist() will get us the list of (sub-)matches, which we'll inject
	" into the passed expression via a s:Submatch() surrogate function for
	" submatch().
	let l:emulatedSub = substitute(a:sub[2:], '\w\@<!submatch\s*(', 's:Submatch(', 'g')

	if a:flags ==# 'g'
	    " For a global replacement, we need to separate the pattern matches
	    " from the surrounding text, and process each match in turn.
	    let l:innerParts = ingo#collections#SplitKeepSeparators(a:expr, a:pat, 1)
	    let l:replacement = ''
	    let l:innerPrefix = ''
	    while ! empty(l:innerParts)
		let l:innerSurroundingText = remove(l:innerParts, 0)
		if empty(l:innerParts)
		    let l:replacement .= l:innerSurroundingText
		else
		    let l:innerExpr = remove(l:innerParts, 0)

		    " To enable the use of lookahead and lookbehind, include the
		    " text before the current match (but nothing more, as that
		    " processed match would else match again) as well as all the
		    " text after it.
		    let l:augmentedInnerExpr = l:innerPrefix . l:innerSurroundingText . l:innerExpr . join(l:innerParts, '')

		    let l:replacement .= l:innerSurroundingText . s:EmulateSubmatch(l:innerExpr, l:augmentedInnerExpr, a:pat, l:emulatedSub)
		endif

		" To avoid that the ^ anchor matches on subsequent iterations,
		" invalidate the match position by prepending a dummy text that
		" is unlikely to be ever matched by a real pattern.
		let l:innerPrefix = "\<C-_>"
	    endwhile
	else
	    " For a first-only replacement, just match and replace once.
	    let s:submatches = matchlist(a:expr, a:pat)
	    let l:innerReplacement = s:EmulateSubmatch(a:expr, a:expr, a:pat, l:emulatedSub)
	    let l:replacement = substitute(a:expr, a:pat, escape(l:innerReplacement, '\&'), '')
	endif
    else
	let l:replacement = substitute(a:expr, a:pat, a:sub, a:flags)
    endif

    return l:replacement
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
