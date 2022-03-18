" ingo/subst/replacement.vim: Functions for replacing the match of a substitution.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#subst#replacement#ReplaceSpecial( match, replacement, specialExpr, SpecialReplacer )
    if empty(a:specialExpr)
	return a:replacement
    endif

    return join(
    \   map(
    \       ingo#collections#SplitKeepSeparators(a:replacement, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . a:specialExpr),
    \       'call(a:SpecialReplacer, [a:specialExpr, a:match, v:val])'
    \   ),
    \   ''
    \)
endfunction
function! ingo#subst#replacement#DefaultReplacer( expr, match, replacement )
    if a:replacement ==# '\n'
	return "\n"
    elseif a:replacement ==# '\r'
	return "\r"
    elseif a:replacement ==# '\t'
	return "\t"
    elseif a:replacement ==# '\b'
	return "\<BS>"
    elseif a:replacement =~# '^' . a:expr . '$'
	return submatch(a:replacement ==# '&' ? 0 : a:replacement[-1:-1])
    endif
    return ingo#escape#UnescapeExpr(a:replacement, '\%(\\\|' . a:expr . '\)')
endfunction
function! ingo#subst#replacement#DefaultReplacementOnPredicate( predicate, contextObject )
    if a:predicate
	let a:contextObject.lastLnum = line('.')
	if a:contextObject.replacement =~# '^\\='
	    " Handle sub-replace-special.
	    return eval(a:contextObject.replacement[2:])
	else
	    " Handle & and \0, \1 .. \9, and \r\n\t\b (but not \u, \U, etc.)
	    return ingo#subst#replacement#ReplaceSpecial('', a:contextObject.replacement, '\%(&\|\\[0-9rnbt]\)', function('ingo#subst#replacement#DefaultReplacer'))
	endif
    else
	return submatch(0)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
