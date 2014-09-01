" ingo/cmdargs/commandcommands.vim: Functions for parsing of Ex commands that take other Ex commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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

" These built-in commands take an Ex command as an argument.
" You can add your own custom commands to the list via g:commandCommands.
let s:builtInCommandCommands = 'h\%[elp] com\%[mand] verb\%[ose] debug sil\%[ent] redi\%[r] vert\%[ical] lefta\%[bove] abo\%[veleft] rightb\%[elow] bel\%[owright] to\%[pleft] bo\%[tright] argdo bufdo tab tabd\%[o] windo'
let s:builtInCommandCommandsExpr = '\%(' .
\   join(
\       map(
\           split(s:builtInCommandCommands) + (exists('g:commandCommands') ? split(g:commandCommands) : []),
\           'v:val . ''!\?\s\+'''
\       ),
\       '\|'
\   ) .
\   '\)\+'

function! ingo#cmdargs#commandcommands#GetExpr()
    return s:builtInCommandCommandsExpr
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
