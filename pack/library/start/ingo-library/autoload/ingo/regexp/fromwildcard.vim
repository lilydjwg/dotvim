" ingo/regexp/fromwildcard.vim: Functions for converting a shell-like wildcard to a regular expression.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.003	30-Jan-2015	Add
"				ingo#regexp#fromwildcard#AnchoredToPathBoundaries().
"   1.021.002	23-Jun-2014	ENH: Allow to pass path separator to
"				ingo#regexp#fromwildcard#Convert() and
"				ingo#regexp#fromwildcard#IsWildcardPathPattern().
"   1.014.001	26-Oct-2013	file creation from
"				autoload/EditSimilar/Substitute.vim

if exists('+shellslash') && ! &shellslash
    let s:pathSeparator = '\'
    let s:notPathSeparatorPattern = '\\[^/\\\\]'
else
    let s:pathSeparator = '/'
    let s:notPathSeparatorPattern = '\\[^/]'
endif
function! s:AdaptCollection()
    " Special processing for the submatch inside the [...] collection.

    " Earlier, simpler regexp that didn't handle \] inside [...]:
    "let l:expr = substitute(l:expr, '\[\(\%(\^\?\]\)\?.\{-}\)\]', '\\%(\\%(\\[\1]\\\&' . s:notPathSeparatorPattern . '\\)\\|[\1]\\)', 'g')

    " Handle \] inside by including \] in the inner pattern, then undoing the
    " backslash escaping done first in this function (i.e. recreate \] from the
    " initial \\]).
    " Vim doesn't seem to support other escaped characters like [\x6f\d122] in a
    " file pattern.
    let l:result = substitute(submatch(1), '\\\\]', '\\]', 'g')

    " Escape ? and *; the later wildcard expansions will trample over them.
    let l:result = substitute(l:result, '[?*]', '\\\\\0', 'g')

    return l:result
endfunction
function! s:CanonicalizeWildcard( expr, pathSeparator )
    let l:expr = escape(a:expr, '\')

    if a:pathSeparator ==# '\'
	" On Windows, when the 'shellslash' option isn't set (i.e. backslashes
	" are used as path separators), still allow using forward slashes as
	" path separators, like Vim does.
	let l:expr = substitute(l:expr, '/', '\\\\', 'g')
    endif
    return l:expr
endfunction
function! s:Convert( wildcardExpr, ... )
    let l:pathSeparator = (a:0 > 1 ? a:2 : s:pathSeparator)
    let l:expr = s:CanonicalizeWildcard(a:wildcardExpr, l:pathSeparator)

    " [...] wildcards
    let l:expr = substitute(l:expr, '\[\(\%(\^\?\]\)\?\(\\\\\]\|[^]]\)*\)\]', '\="\\%(\\%(\\[". s:AdaptCollection() . "]\\\&' . s:notPathSeparatorPattern . '\\)\\|[". s:AdaptCollection() . "]\\)"', 'g')

    " ? wildcards
    let l:expr = substitute(l:expr, '\\\@<!?', s:notPathSeparatorPattern, 'g')
    let l:expr = substitute(l:expr, '\\\\?', '?', 'g')

    " ** wildcards
    " The ** wildcard matches multiple path elements up to the last path
    " separator; i.e. it doesn't match the filename itself. To implement this
    " restriction, the replacement regexp for ** ends with a zero-width match
    " (so it isn't substituted away) for the path separator if no path separator
    " is already following in the wildcard, anyway.
    " (The l:originalPathspec that is processed in s:Substitute() always has a
    " trailing path separator.)
    "
    " Note: Instead of escaping the '.*' pattern in the replacement (or else
    " it'll be processed as a * wildcard), we use the equivalent '.\{0,}'
    " pattern.
    " Note: The regexp .\{0,}/\@= later substitutes twice if nothing precedes
    " it?! To fix this, we add the ^ anchor when the ** wildcard appears at the
    " beginning.
    if l:pathSeparator ==# '\'
	" If backslash is the path separator, one cannot escape the ** wildcard.
	" That isn't necessary, anyway, because Windows doesn't allow the '*'
	" character in filespecs.
	let l:expr = substitute(l:expr, '\\\\\zs\*\*$', '\\.\\{0,}\\%(\\\\\\)\\@=', 'g')
	let l:expr = substitute(l:expr, '^\*\*$', '\\^\\.\\{0,}\\%(\\\\\\)\\@=', 'g')
	let l:expr = substitute(l:expr, '\%(^\|\\\\\)\zs\*\*\ze\\\\', '\\.\\{0,}', 'g')
    else
	let l:expr = substitute(l:expr, '/\zs\*\*$', '\\.\\{0,}/\\@=', 'g')
	let l:expr = substitute(l:expr, '^\*\*$', '\\^\\.\\{0,}/\\@=', 'g')
	let l:expr = substitute(l:expr, '\%(^\|/\)\zs\*\*\ze/', '\\.\\{0,}', 'g')
	" Convert the escaped \** to \*\*, so that the following * wildcard
	" substitution converts that to **.
	let l:expr = substitute(l:expr, '\\\\\*\*', '\\\\*\\\\*', 'g')
    endif

    " * wildcards
    let l:expr = substitute(l:expr, '\\\@<!\*', s:notPathSeparatorPattern . '\\*', 'g')
    let l:expr = substitute(l:expr, '\\\\\*', '*', 'g')

    let l:additionalEscapeCharacters = (a:0 ? a:1 : '')
    return [l:expr, l:additionalEscapeCharacters, l:pathSeparator]
endfunction
function! ingo#regexp#fromwildcard#Convert( ... )
"*******************************************************************************
"* PURPOSE:
"   Convert a shell-like a:wildcardExpr which may contain wildcards (?, *, **,
"   [...]) into an (unanchored!) regular expression.
"
"   In constrast to the simpler ingo#regexp#FromWildcard(), this handles the
"   full range of wildcards and considers the path separators on different
"   platforms.
"
"* SEE ALSO:
"   For automatic anchoring, use
"   ingo#regexp#fromwildcard#AnchoredToPathBoundaries().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:wildcardExpr  Text containing file wildcards.
"   a:additionalEscapeCharacters    For use in the / command, add '/', for the
"				    backward search command ?, add '?'. For
"				    assignment to @/, always add '/', regardless
"				    of the search direction; this is how Vim
"				    escapes it, too. For use in search(), pass
"				    nothing / omit the argument.
"   a:pathSeparator Optional fixed value for the path separator, to use instead
"		    of the platform's default one.
"* RETURN VALUES:
"   Regular expression for matching a:wildcardExpr.
"*******************************************************************************
    let [l:expr, l:additionalEscapeCharacters, l:pathSeparator] = call('s:Convert', a:000)
    return '\V' . escape(l:expr, l:additionalEscapeCharacters)
endfunction
function! ingo#regexp#fromwildcard#AnchoredToPathBoundaries( ... )
"*******************************************************************************
"* PURPOSE:
"   Convert a shell-like a:wildcardExpr which may contain wildcards (?, *, **,
"   [...]) into a regular expression anchored to path boundaries; i.e.
"   a:wildcardExpr must match complete path components delimited by the
"   a:pathSeparator or the start / end of the String.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:wildcardExpr  Text containing file wildcards.
"   a:additionalEscapeCharacters    For use in the / command, add '/', for the
"				    backward search command ?, add '?'. For
"				    assignment to @/, always add '/', regardless
"				    of the search direction; this is how Vim
"				    escapes it, too. For use in search(), pass
"				    nothing / omit the argument.
"   a:pathSeparator Optional fixed value for the path separator, to use instead
"		    of the platform's default one.
"* RETURN VALUES:
"   Regular expression for matching a:wildcardExpr.
"*******************************************************************************
    let [l:expr, l:additionalEscapeCharacters, l:pathSeparator] = call('s:Convert', a:000)
    let l:pathSeparator = escape(l:pathSeparator, '\')

    let l:prefix = printf('\%%(\^\|%s\@<=\)', l:pathSeparator)
    let l:suffix = printf('\%%(\$\|%s\@=\)', l:pathSeparator)
    return '\V' . escape(l:prefix . l:expr . l:suffix, l:additionalEscapeCharacters)
endfunction

function! ingo#regexp#fromwildcard#IsWildcardPathPattern( expr, ... )
    let l:pathSeparator = (a:0 ? a:1 : s:pathSeparator)
    let l:expr = s:CanonicalizeWildcard(a:expr, l:pathSeparator)
    let l:pathSeparatorExpr = escape(l:pathSeparator, '\')

    " Check for ** wildcard.
    if l:expr =~ '\%(^\|'. l:pathSeparatorExpr . '\)\zs\*\*\ze\%(' . l:pathSeparatorExpr . '\|$\)'
	return 1
    endif

    " Check for path separator outside of [...] wildcards.
    if substitute(l:expr, '\[\(\%(\^\?\]\)\?\(\\\\\]\|[^]]\)*\)\]', '', 'g') =~ l:pathSeparatorExpr
	return 1
    endif

    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
