" ingo/cmdargs/range.vim: Functions for parsing Ex command ranges.
"
" DEPENDENCIES:
"   - ingo/cmdargs/commandcommands.vim autoload script
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.007	10-Jun-2014	ENH: Add a:options.commandExpr to
"				ingo#cmdargs#range#Parse().
"   1.010.006	08-Jul-2013	Move into ingo-library.
"   	005	14-Jun-2013	Minor: Make matchlist() robust against
"				'ignorecase'.
"	004	31-May-2013	Add ingoexcommands#ParseRange().
"				FIX: :* is also a valid range: shortcut for
"				'<,'>.
"	003	30-Dec-2012	Add missing ":help" and ":command" to
"				s:builtInCommandCommands.
"	002	19-Jun-2012	Return all parsed fragments in
"				ingoexcommands#ParseCommand() so that the
"				command can be re-assembled again.
"				Allow parsing of whitespace-separated arguments,
"				too, by passing in an optional regexp for them.
"	001	15-Jun-2012	file creation
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
"				    True by default.
"   a:options.commandExpr           Custom pattern for matching commands /
"				    anything that follows the range. Mutually
"				    exclusive with
"				    a:options.isAllowEmptyCommand.
"   a:options.isParseFirstRange     Flag whether the first range should be
"				    parsed. False by default.
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
    let l:commandExpr = get(l:options, 'commandExpr', (l:isAllowEmptyCommand ? '\(\h\w*.*\|$\)' : '\(\h\w*.*\)'))

    let l:parseExpr =
    \	(l:isParseFirstRange ? '\C^\(\s*\)' : '\C^\(.*\\\@<!|\)\?\s*') .
    \	'\(' . ingo#cmdargs#commandcommands#GetExpr() . '\)\?' .
    \	'\(' . ingo#cmdargs#range#RangeExpr() . '\)\s*' .
    \   l:commandExpr
    return matchlist(a:commandLine, l:parseExpr)[0:4]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
