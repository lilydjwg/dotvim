" ingo/cmdargs.vim: Functions for parsing of command arguments.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.008	22-Apr-2015	FIX: ingo#cmdargs#GetStringExpr(): Escape
"				(unescaped) double quotes when the argument
"				contains backslashes; else, the expansion of \x
"				will silently fail.
"				Add ingo#cmdargs#GetUnescapedExpr(); when
"				there's no need for empty expressions, the
"				removal of the (single / double) quotes may be
"				unexpected.
"   1.007.007	01-Jun-2013	Move functions from ingo/cmdargs.vim to
"				ingo/cmdargs/pattern.vim and
"				ingo/cmdargs/substitute.vim.
"   1.006.006	29-May-2013	Again change
"				ingo#cmdargs#ParseSubstituteArgument() interface
"				to parse the :substitute [flags] [count] by
"				default.
"   1.006.005	28-May-2013	BUG: ingo#cmdargs#ParseSubstituteArgument()
"				mistakenly returns a:defaultFlags when full
"				/pat/repl/ or a literal pat is passed. Only
"				return a:defaultFlags when the passed
"				a:arguments is really empty.
"				CHG: Redesign
"				ingo#cmdargs#ParseSubstituteArgument() interface
"				to the existing use cases. a:defaultReplacement
"				should only be used when a:arguments is really
"				empty, too. Introduce an optional options
"				Dictionary and preset replacement / flags
"				defaults of "~" and "&" resp. for when
"				a:arguments is really empty, which makes sense
"				for use with :substitute. Allow submatches for
"				a:flagsExpr via a:options.flagsMatchCount, to
"				avoid further parsing in the client.
"				ENH: Also parse lone {flags} (if a:flagsExpr is
"				given) by default, and allow to turn this off
"				via a:options.isAllowLoneFlags.
"				ENH: Allow to pass a:options.emptyPattern, too.
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

function! ingo#cmdargs#GetUnescapedExpr( argument )
    try
	if a:argument =~# '\\'
	    " The argument contains escape characters, evaluate them.
	    execute 'let l:expr = "' . substitute(a:argument, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!"', '\\"', 'g') . '"'
	else
	    let l:expr = a:argument
	endif
    catch /^Vim\%((\a\+)\)\=:/
	let l:expr = a:argument
    endtry
    return l:expr
endfunction
function! ingo#cmdargs#GetStringExpr( argument )
    try
	if a:argument =~# '^\([''"]\).*\1$'
	    " The argument is quoted, evaluate it.
	    execute 'let l:expr =' a:argument
	elseif a:argument =~# '\\'
	    " The argument contains escape characters, evaluate them.
	    execute 'let l:expr = "' . substitute(a:argument, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!"', '\\"', 'g') . '"'
	else
	    let l:expr = a:argument
	endif
    catch /^Vim\%((\a\+)\)\=:/
	let l:expr = a:argument
    endtry
    return l:expr
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
