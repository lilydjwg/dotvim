" ingo/cmdargs/command.vim: Functions for parsing of Ex commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

" Commands are usually <Space>-delimited, but can also be directly followed by
" an argument (like :substitute, :ijump, etc.). According to :help E146, the
" delimiter can be almost any single-byte character.
" Note: We use branches, not a (better performing?) single /[...]/ atom, because
" of the uncertainties of escaping these characters.
function! s:IsCmdDelimiter(char)
    " Note: <Space> and <Tab> must not be included in the set of delimiters;
    " otherwise, the detection of commands that take other commands
    " (ingo#cmdargs#commandcommands#GetExpr()) won't work any more (because the
    " combination of "command<Space>alias" is matched as commandUnderCursor).
    " There's no need to include <Space> anyway; since this is our mapped trigger
    " key, any alias expansion should already have happened earlier.
    return (len(a:char) == 1 && a:char !~# '[[:space:][:alpha:][:digit:]\\"|]')
endfunction
let s:cmdDelimiterExpr = '\V\C\%(' .
\ join(
\   filter(
\     map(
\       range(0, 255),
\       'nr2char(v:val)'
\     ),
\     's:IsCmdDelimiter(v:val)'
\   ),
\   '\|'
\ ). '\)\m'
function! ingo#cmdargs#command#DelimiterExpr()
    return s:cmdDelimiterExpr
endfunction

function! ingo#cmdargs#command#Parse( commandLine, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:commandLine into Ex command fragments. When the command line
"   contains multiple commands, the last one is parsed. Arguments that directly
"   follow the command (e.g. ":%s/foo/bar/") are handled, but no
"   whitespace-separated arguments must follow.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:commandLine   Ex command line containing a command.
"   a:argumentExpr  Regular expression for matching arguments; probably should
"                   be anchored to the end via /$/. When not given, no
"                   whitespace-separated arguments must follow the command for
"                   the parsing to succeed; it will only parse no-argument
"                   commands then!
"                   To parse |:bar| commands that see | as their argument, use
"                   '.*$'
"                   To parse any regular commands (without -bar), use a pattern
"                   that excludes the | command separator, e.g.
"                   '\%([^|]\|\\|\)*$'. You can also supply the special argument
"                   value "*" for that.
"   a:directArgumentExpr    Regular expression for matching direct arguments.
"			    Defaults to parsing of arbitrary direct arguments.
"* RETURN VALUES:
"   List of [fullCommandUnderCursor, combiner, range, commandCommands, commandName, commandBang, commandDirectArgs, commandArgs]
"   where:
"	fullCommandUnderCursor  The entire command, potentially starting with
"				"|" when there's a command chain.
"	combiner    Empty, white space, or something with "|" that joins the
"		    command to the previous one.
"	commandCommands Empty or any prepended commands take another Ex command
"			as an argument.
"	range       The single or double line address(es), e.g. "42,'b".
"	commandName Name of the command.
"	bang        Optional "!" following the command.
"	commandDirectArgs   Any arguments directly following the command, e.g.
"			    "/foo/b a r/".
"	commandArgs         Any normal, whitespace-delimited arguments,
"			    including the leading delimiter. Will be empty when
"			    a:argumentExpr is not given or when
"			    commandDirectArgs is not empty.
"   Or: [] if no match.
"
"   To reassemble, you can concatenate [1:7] together; originally, that's the
"   same as [0].
"   To get the cut-off previous command(s), you can use >
"	strpart(a:commandLine, 0, len(a:commandLine) - len(l:parse[0]))
"   <
"******************************************************************************
    let l:commandPattern =
    \	'\(' . ingo#cmdargs#commandcommands#GetExpr() . '\)\?' .
    \	'\(' . ingo#cmdargs#range#RangeExpr() . '\)\s*' .
    \	'\(\h\w*\)\(!\?\)\(' . ingo#cmdargs#command#DelimiterExpr() . (a:0 > 1 ? a:2 : '.*') . '\)\?' .
    \   '\(' . (a:0 && ! empty(a:1) ? '$\|\s\+' . (a:1 ==# '*' ? '\%([^|]\|\\|\)*$' : a:1) : '$') . '\)'

    for l:anchor in ['\s*\\\@<!|\s*', '^\s*']
	let l:parse = matchlist(a:commandLine,
	\   printf('\C\(%s\)', l:anchor) . l:commandPattern
	\)
	if ! empty(l:parse)
	    break
	endif
    endfor

    return l:parse[0:7]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
