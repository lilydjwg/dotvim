" ingo/cmdargs/range.vim: Functions for parsing Ex command ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:singleRangeExpr = '\%(\d*\|[.$*%]\|''\S\|\\[/?&]\|/.\{-}/\|?.\{-}?\)\%([+-]\d*\)\?'
let s:rangeExpr = s:singleRangeExpr . '\%([,;]' . s:singleRangeExpr . '\)\?'
function! ingo#cmdargs#range#SingleRangeExpr()
    return s:singleRangeExpr
endfunction
function! ingo#cmdargs#range#RangeExpr()
    return s:rangeExpr
endfunction

function! ingo#cmdargs#range#Parse( commandLine, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:commandLine into the range and the remainder. When the command line
"   contains multiple commands, the last one is parsed.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:commandLine   Ex command line containing a command.
"   a:options.isAllowEmptyCommand   Flag whether a sole range should be matched.
"				    A completely empty a:commandLine won't be
"				    accepted; there has to be a range and/or a
"				    command. True by default.
"   a:options.commandExpr           Custom pattern for matching commands /
"				    anything that follows the range. Mutually
"				    exclusive with
"				    a:options.isAllowEmptyCommand.
"   a:options.isParseFirstRange     Flag whether the first range should be
"				    parsed. False by default.
"   a:options.isOnlySingleAddress   Flag whether only a single address should be
"                                   allowed, and double line addresses are not
"                                   recognized as valid. False by default.
"* RETURN VALUES:
"   List of [fullCommandUnderCursor, combiner, commandCommands, range, remainder]
"	fullCommandUnderCursor  The entire command, potentially starting with
"				"|" when there's a command chain.
"	combiner    Empty, white space, or something with "|" that joins the
"		    command to the previous one.
"	commandCommands Empty or any prepended commands take another Ex command
"			as an argument.
"	range       The single or double line address(es), e.g. "42,'b".
"	remainder   The command; possibly empty (when a:isAllowEmptyCommand is
"		    true).
"   Or: [] if no match.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isAllowEmptyCommand = get(l:options, 'isAllowEmptyCommand', 1)
    let l:isParseFirstRange = get(l:options, 'isParseFirstRange', 0)
    let l:rangeExpr = (get(l:options, 'isOnlySingleAddress', 0) ?
    \   ingo#cmdargs#range#SingleRangeExpr() :
    \   ingo#cmdargs#range#RangeExpr()
    \)
    let l:commandExpr = get(l:options, 'commandExpr', (l:isAllowEmptyCommand ? '\(\h\w*.*\|$\)' : '\(\h\w*.*\)'))

    let l:parseExpr =
    \	(l:isParseFirstRange ? '\C^\(\s*\)' : '\C^\(.*\\\@<!|\)\?\s*') .
    \	'\(' . ingo#cmdargs#commandcommands#GetExpr() . '\)\?' .
    \	'\(' . l:rangeExpr . '\)\s*' .
    \   l:commandExpr
    let l:commandParse = matchlist(a:commandLine, l:parseExpr)[0:4]
    return (l:commandParse == ['', '', '', '', ''] ? [] : l:commandParse)
endfunction

function! ingo#cmdargs#range#ParsePrependedRange( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments into a range at the beginning, and any following stuff,
"   separated by non-alphanumeric character or whitespace (or the optional
"   a:directSeparator).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:options.directSeparator   Optional regular expression for the separator
"                               (parsed into text) between the text and range
"                               (with optional whitespace in between; mandatory
"                               whitespace is always an alternative). Defaults
"                               to any whitespace. If empty: there must be
"                               whitespace between text and register.
"   a:options.isPreferText      Optional flag that if the arguments consist
"                               solely of an range, whether this is counted as
"                               text (1, default) or as a sole range (0).
"   a:options.isOnlySingleAddress   Flag whether only a single address should be
"                                   allowed, and double line addresses are not
"                                   recognized as valid. False by default.
"* RETURN VALUES:
"   [address, text], or ['', a:arguments] if no address could be parsed.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:rangeExpr = (get(l:options, 'isOnlySingleAddress', 0) ?
    \   ingo#cmdargs#range#SingleRangeExpr() :
    \   ingo#cmdargs#range#RangeExpr()
    \)
    let l:directSeparator = (empty(get(l:options, 'directSeparator', '')) ?
    \   '\%$\%^' :
    \   get(l:options, 'directSeparator', '')
    \)
    let l:isPreferText = get(l:options, 'isPreferText', 1)

    let l:matches = matchlist(a:arguments, '^\(' . l:rangeExpr . '\)\%(\%(\s*' . l:directSeparator . '\)\@=\|\s\+\)\(.*\)$')
    return (empty(l:matches) ?
    \   (! l:isPreferText && a:arguments =~# '^' . l:rangeExpr . '$' ?
    \       [a:arguments , ''] :
    \       ['', a:arguments]
    \   ) :
    \   l:matches[1:2]
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
