" ingo/cmdargs/pattern.vim: Functions for parsing of pattern arguments of commands.
"
" DEPENDENCIES:
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.003	29-May-2014	Use ingo#escape#Unescape() in
"				ingo#cmdargs#pattern#Unescape().
"				Add ingo#cmdargs#pattern#ParseUnescaped() to
"				avoid the double and inefficient
"				ingo#cmdargs#pattern#Unescape(ingo#cmdargs#pattern#Parse())
"				Add
"				ingo#cmdargs#pattern#ParseUnescapedWithLiteralWholeWord()
"				for the common [/]{pattern}[/ behavior as
"				built-in commands like |:djump|]. When the
"				pattern isn't delimited by /.../, the returned
"				pattern is modified so that only literal whole
"				words are matched.
"				so far used by many clients.
"   1.011.002	24-Jul-2013	FIX: Use the rules for the /pattern/ separator
"				as stated in :help E146.
"   1.007.001	01-Jun-2013	file creation

function! s:Parse( arguments, ... )
    return matchlist(a:arguments, '^\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1' . (a:0 ? a:1 : '') . '$')
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
"* RETURN VALUES:
"   [separator, escapedPattern]; if a:flagsExpr is given
"   [separator, escapedPattern, flags]. In a:escapedPattern, the a:separator is
"   consistently escaped (i.e. also when the original arguments haven't been
"   enclosed in such).
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	return ['/', escape(a:arguments, '/')] + (a:0 ? [''] : [])
    else
	return l:match[1: (a:0 ? 3 : 2)]
    endif
endfunction
function! ingo#cmdargs#pattern#ParseUnescaped( arguments, ... )
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
"* RETURN VALUES:
"   unescapedPattern (String); if a:flagsExpr is given instead List of
"   [unescapedPattern, flags]. In a:unescapedPattern, any separator used in
"   a:arguments is unescaped.
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	return (a:0 ? [a:arguments, ''] : a:arguments)
    else
	let l:unescapedPattern = ingo#escape#Unescape(l:match[2], l:match[1])
	return (a:0 ? [l:unescapedPattern, l:match[3]] : l:unescapedPattern)
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
"* RETURN VALUES:
"   unescapedPattern (String); if a:flagsExpr is given instead List of
"   [unescapedPattern, flags]. In a:unescapedPattern, any separator used in
"   a:arguments is unescaped.
"******************************************************************************
    let l:match = call('s:Parse', [a:arguments] + a:000)
    if empty(l:match)
	let l:unescapedPattern = ingo#regexp#FromLiteralText(a:arguments, 1, '')
	return (a:0 ? [l:unescapedPattern, ''] : l:unescapedPattern)
    else
	let l:unescapedPattern = ingo#escape#Unescape(l:match[2], l:match[1])
	return (a:0 ? [l:unescapedPattern, l:match[3]] : l:unescapedPattern)
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
