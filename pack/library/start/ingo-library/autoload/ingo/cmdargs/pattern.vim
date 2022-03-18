" ingo/cmdargs/pattern.vim: Functions for parsing of pattern arguments of commands.
"
" DEPENDENCIES:
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#cmdargs#pattern#PatternExpr( ... ) abort
    return '\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\' . (a:0 ? a:1 : 1)
endfunction
function! s:Parse( arguments, ... )
    return matchlist(a:arguments, '^' . ingo#cmdargs#pattern#PatternExpr() . (a:0 ? a:1 : '') . '$')
endfunction
function! ingo#cmdargs#pattern#RawParse( arguments, returnValueOnNoMatch, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments as a pattern delimited by non-optional /.../ (or similar)
"   characters, and with optional following flags match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:returnValueOnNoMatch  Value that will be returned when a:arguments are not
"			    a delimited pattern.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"   a:flagsMatchCount Number of capture groups returned from a:flagsExpr.
"* RETURN VALUES:
"   a:returnValueOnNoMatch if no match
"   [separator, escapedPattern]; if a:flagsExpr is given
"   [separator, escapedPattern, flags, ...].
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	return a:returnValueOnNoMatch
    else
	return l:match[1: (a:0 ? (a:0 >= 2 ? a:2 + 2 : 3) : 2)]
    endif
endfunction
function! ingo#cmdargs#pattern#Parse( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments as a pattern delimited by optional /.../ (or similar)
"   characters, and with optional following flags match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"   a:flagsMatchCount Number of capture groups returned from a:flagsExpr.
"* RETURN VALUES:
"   [separator, escapedPattern]; if a:flagsExpr is given
"   [separator, escapedPattern, flags, ...].
"   In a:escapedPattern, the a:separator is consistently escaped (i.e. also when
"   the original arguments haven't been enclosed in such).
"******************************************************************************
    " Note: We could delegate to ingo#cmdargs#pattern#RawParse(), but let's
    " duplicate this for now to avoid another redirection.
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	return ['/', escape(a:arguments, '/')] + (a:0 ? repeat([''], a:0 >= 2 ? a:2 : 1) : [])
    else
	return l:match[1: (a:0 ? (a:0 >= 2 ? a:2 + 2 : 3) : 2)]
    endif
endfunction
function! ingo#cmdargs#pattern#ParseWithLiteralWholeWord( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments as a pattern delimited by optional /.../ (or similar)
"   characters, and with optional following flags match. When the pattern isn't
"   delimited by /.../, the returned pattern is modified so that only literal
"   whole words are matched. Built-in commands like |:djump| also have this
"   behavior: |:search-args|
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"   a:flagsMatchCount Number of capture groups returned from a:flagsExpr.
"* RETURN VALUES:
"   [separator, escapedPattern]; if a:flagsExpr is given
"   [separator, escapedPattern, flags, ...].
"   In a:escapedPattern, the a:separator is consistently escaped (i.e. also when
"   the original arguments haven't been enclosed in such).
"******************************************************************************
    " Note: We could delegate to ingo#cmdargs#pattern#RawParse(), but let's
    " duplicate this for now to avoid another redirection.
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	let l:pattern = ingo#regexp#FromLiteralText(a:arguments, 1, '/')
	return ['/', l:pattern] + (a:0 ? repeat([''], a:0 >= 2 ? a:2 : 1) : [])
    else
	return l:match[1: (a:0 ? (a:0 >= 2 ? a:2 + 2 : 3) : 2)]
    endif
endfunction
function! ingo#cmdargs#pattern#ParseUnescaped( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments as a pattern delimited by optional /.../ (or similar)
"   characters, and with optional following flags match.
"   You can use this function to check for delimiting /.../ characters, and then
"   either react on the (unescaped) pattern, or take the literal original
"   string:
"	let l:pattern = ingo#cmdargs#pattern#ParseUnescaped(a:argument)
"	if l:pattern !=# a:argument
"	    " Pattern-based processing with l:pattern.
"	else
"	    " Literal processing with a:argument
"	endif
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"   a:flagsMatchCount Number of capture groups returned from a:flagsExpr.
"* RETURN VALUES:
"   unescapedPattern (String); if a:flagsExpr is given instead List of
"   [unescapedPattern, flags, ...]. In a:unescapedPattern, any separator used in
"   a:arguments is unescaped.
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	return (a:0 ? [a:arguments] + repeat([''], a:0 >= 2 ? a:2 : 1) : a:arguments)
    else
	let l:unescapedPattern = ingo#escape#Unescape(l:match[2], l:match[1])
	return (a:0 ? [l:unescapedPattern] + l:match[3: (a:0 >= 2 ? a:2 + 2 : 3)] : l:unescapedPattern)
    endif
endfunction
function! ingo#cmdargs#pattern#ParseUnescapedWithLiteralWholeWord( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments as a pattern delimited by optional /.../ (or similar)
"   characters, and with optional following flags match. When the pattern isn't
"   delimited by /.../, the returned pattern is modified so that only literal
"   whole words are matched. Built-in commands like |:djump| also have this
"   behavior: |:search-args|
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"   a:flagsMatchCount Number of capture groups returned from a:flagsExpr.
"* RETURN VALUES:
"   unescapedPattern (String); if a:flagsExpr is given instead List of
"   [unescapedPattern, flags, ...]. In a:unescapedPattern, any separator used in
"   a:arguments is unescaped.
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	let l:unescapedPattern = ingo#regexp#FromLiteralText(a:arguments, 1, '')
	return (a:0 ? [l:unescapedPattern] + repeat([''], a:0 >= 2 ? a:2 : 1) : l:unescapedPattern)
    else
	let l:unescapedPattern = ingo#escape#Unescape(l:match[2], l:match[1])
	return (a:0 ? [l:unescapedPattern] + l:match[3: (a:0 >= 2 ? a:2 + 2 : 3)] : l:unescapedPattern)
    endif
endfunction

function! ingo#cmdargs#pattern#Unescape( parsedArguments )
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
"			ingo#cmdargs#pattern#Parse() in here.
"* RETURN VALUES:
"   If a:parsedArguments contains exactly two arguments: unescaped pattern.
"   Else a List where the first element is the unescaped pattern, and all
"   following elements are taken from the remainder of a:parsedArguments.
"******************************************************************************
    " We don't need the /.../ separation here.
    let l:separator = a:parsedArguments[0]
    let l:unescapedPattern = (empty(l:separator) ?
    \   a:parsedArguments[1] :
    \   ingo#escape#Unescape(a:parsedArguments[1], l:separator)
    \)

    return (len(a:parsedArguments) > 2 ? [l:unescapedPattern] + a:parsedArguments[2:] : l:unescapedPattern)
endfunction

function! ingo#cmdargs#pattern#IsDelimited( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Test whether a:arguments is delimited by pattern separators (and optionally
"   appended flags).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:flagsExpr Pattern that captures any optional part after the pattern.
"* RETURN VALUES:
"   1 if delimited by suitable, identical characters (plus any flags as
"   specified by a:flagsExpr), else 0.
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    return (! empty(l:match))
endfunction

function! ingo#cmdargs#pattern#Render( arguments )
"******************************************************************************
"* PURPOSE:
"   Create a single string from the parsed pattern arguments.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Return value from any of the ...#Parse... methods defined here.
"* RETURN VALUES:
"   String with separator-delimited pattern, followed by any additional flags,
"   etc.
"******************************************************************************
    return a:arguments[0] . a:arguments[1] . a:arguments[0] . join(a:arguments[2:], '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
