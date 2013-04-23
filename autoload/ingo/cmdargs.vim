" ingo/cmdargs.vim: Functions for parsing of command arguments.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.001.004	21-Feb-2013	Move to ingo-library.
"	003	29-Jan-2013	Add ingocmdargs#ParseSubstituteArgument() for
"				use in PatternsOnText/Except.vim and
"				ExtractMatchesToReg.vim.
"				Change ingocmdargs#UnescapePatternArgument() to
"				take the result of
"				ingocmdargs#ParsePatternArgument() instead of
"				invoking that function itself. And make it
"				handle an empty separator.
"	002	21-Jan-2013	Add ingocmdargs#ParsePatternArgument() and
"				ingocmdargs#UnescapePatternArgument() from
"				PatternsOnText.vim.
"	001	25-Nov-2012	file creation from CaptureClipboard.vim.

function! ingo#cmdargs#GetStringExpr( argument )
    try
	if a:argument =~# '^\([''"]\).*\1$'
	    " The argument is quotes, evaluate it.
	    execute 'let l:expr =' a:argument
	elseif a:argument =~# '\\'
	    " The argument contains escape characters, evaluate them.
	    execute 'let l:expr = "' . a:argument . '"'
	else
	    let l:expr = a:argument
	endif
    catch /^Vim\%((\a\+)\)\=:E/
	let l:expr = a:argument
    endtry
    return l:expr
endfunction


function! ingo#cmdargs#ParsePatternArgument( arguments, ... )
    let l:match = matchlist(a:arguments, '^\(\i\@!\S\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1' . (a:0 ? a:1 : '') . '$')
    if empty(l:match)
	return ['/', escape(a:arguments, '/')] + (a:0 ? [''] : [])
    else
	return l:match[1: (a:0 ? 3 : 2)]
    endif
endfunction
function! ingo#cmdargs#UnescapePatternArgument( parsedArguments )
"******************************************************************************
"* PURPOSE:
"   Unescape the use of the separator from the parsed pattern to yield a plain
"   regular expression, e.g. for use in search().
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:parsedArguments   List with at least two elements: [separator, pattern].
"			separator may be empty; in that case; pattern is
"			returned as-is.
"			You're meant to directly pass the output of
"			ingo#cmdargs#ParsePatternArgument() in here.
"* RETURN VALUES:
"   If a:parsedArguments contains exactly two arguments: unescaped pattern.
"   Else a List where the first element is the unescaped pattern, and all
"   following elements are taken from the remainder of a:parsedArguments.
"******************************************************************************
    " We don't need the /.../ separation here.
    let l:separator = a:parsedArguments[0]
    let l:unescapedPattern = (empty(l:separator) ?
    \   a:parsedArguments[1] :
    \   substitute(a:parsedArguments[1], '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\V\C' . l:separator, l:separator, 'g')
    \)

    return (len(a:parsedArguments) > 2 ? [l:unescapedPattern] + a:parsedArguments[2:] : l:unescapedPattern)
endfunction

function! ingo#cmdargs#ParseSubstituteArgument( arguments, defaultReplacement, ... )
"******************************************************************************
"* PURPOSE:
"   Parse the arguments of a custom command that works like :substitute.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:arguments The command's raw arguments; usually <q-args>.
"   a:defaultReplacement    Replacement to use when the replacement part is
"			    omitted.
"   a:defaultFlags          Optional: Flags to use when a:flagsExpr is passed,
"			    but no arguments at all are given.
"   a:flagsExpr             Optional: Pattern that captures any optional part
"			    after the replacement (usually some substitution
"			    flags).
"* RETURN VALUES:
"   A list of [separator, pattern, replacement] or [separator, pattern,
"   replacement, flags] when the optional arguments are passed.
"   The replacement part is always escaped for use inside separator, also when
"   the default is taken.
"******************************************************************************
    let l:matches = matchlist(a:arguments, '^\(\i\@!\S\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1' . (a:0 ? a:2 : '') . '$')
    if ! empty(l:matches)
	" Full /pat/repl/[flags].
	return l:matches[1:3] + [(a:0 && ! empty(l:matches[4]) ? l:matches[4] : a:1)]
    endif

    let l:matches = matchlist(a:arguments, '^\(\i\@!\S\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1\(.\{-}\)$')
    if ! empty(l:matches)
	" Partial /pat/[repl].
	return l:matches[1:2] + [(empty(l:matches[3]) ? escape(a:defaultReplacement, l:matches[1]) : l:matches[3])] + (a:0 ? [''] : [])
    endif

    let l:matches = matchlist(a:arguments, '^\(\i\@!\S\)\(.\{-}\)$')
    if ! empty(l:matches)
	" Minimal /[pat].
	return l:matches[1:2] + [escape(a:defaultReplacement, l:matches[1])] + (a:0 ? [''] : [])
    elseif ! empty(a:arguments)
	" Literal pat.
	return ['', a:arguments, a:defaultReplacement] + (a:0 ? [a:1] : [])
    else
	" Nothing.
	return ['/', '', escape(a:defaultReplacement, '/')] + (a:0 ? [a:1] : [])
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
