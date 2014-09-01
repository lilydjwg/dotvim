" ingo/cmdargs/file.vim: Functions for handling file arguments to commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.003	11-Feb-2014	CHG: Make
"				ingo#cmdargs#file#FilterFileOptionsAndCommands()
"				return the options and commands in a List, not
"				as a joined String. This allows clients to
"				easily re-escape them and handle multiple ones,
"				e.g. ++ff=dos +setf\ foo.
"   1.009.002	14-Jun-2013	Minor: Make matchlist() robust against
"				'ignorecase'.
"   1.007.001	01-Jun-2013	file creation from ingofileargs.vim

function! ingo#cmdargs#file#FilterEscapedFileOptionsAndCommands( arguments )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt +cmd file options and commands.
"
"   (In Vim 7.2,) options and commands can only appear at the beginning of the
"   file list; there can be multiple options, but only one command. They are
"   only applied to the first (opened) file, not to any other passed file.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Original file argument(s), derived e.g. via <q-args>.
"		If you need unescaped file arguments later anyway, use
"		ingo#cmdargs#file#FilterFileOptionsAndCommands() instead.
"* RETURN VALUES:
"   [fileOptionsAndCommands, filename]	First element is a string containing all
"   removed file options and commands. This includes any trailing whitespace, so
"   it can be directly concatenated with filename, the second argument.
"*******************************************************************************
    return matchlist(a:arguments,
    \   '\C^\(' .
    \       '\%(++\%(ff\|fileformat\|enc\|encoding\|bin\|binary\|nobin\|nobinary\|bad\|edit\)\%(=\S*\)\?\s\+\)*' .
    \	    '\%(+.\{-}\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<! \s*\)\?' .
    \   '\)\(.*\)$'
    \)[1:2]
endfunction

function! ingo#cmdargs#file#FilterFileOptionsAndCommands( fileglobs )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt +cmd file options and commands.
"
"   (In Vim 7.2,) options and commands can only appear at the beginning of the
"   file list; there can be multiple options, but only one command. They are
"   only applied to the first (opened) file, not to any other passed file.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:fileglobs Raw list of file patterns. To get this from a <q-args> string,
"		use ingo#cmdargs#file#SplitAndUnescape(). Or alternatively
"		use ingo#cmdargs#file#FilterEscapedFileOptionsAndCommands().
"* RETURN VALUES:
"   [a:fileglobs, fileOptionsAndCommands]	First element is the passed
"   list, with any file options and commands removed. Second element is a List
"   containing all removed file options and commands.
"   Note: If the file arguments were obtained through
"   ingo#cmdargs#file#SplitAndUnescape(), these must be re-escaped for use
"   in another Ex command:
"	join(map(l:fileOptionsAndCommands, "escape(v:val, '\\ ')"))
"*******************************************************************************
    let l:startIdx = 0
    while get(a:fileglobs, l:startIdx, '') =~# '^+\{1,2}'
	if l:startIdx > 0 && a:fileglobs[l:startIdx - 1] !~# '^++' && a:fileglobs[l:startIdx] !~# '^++'
	    " There can be multiple ++opt arguments, followed by only one
	    " possible +cmd argument.
	    break
	endif

	let l:startIdx += 1
    endwhile

    if l:startIdx == 0
	return [a:fileglobs, []]
    else
	return [a:fileglobs[l:startIdx : ], a:fileglobs[ : (l:startIdx - 1)]]
    endif
endfunction

function! ingo#cmdargs#file#Unescape( fileArgument )
"******************************************************************************
"* PURPOSE:
"   Unescape spaces in a:fileArgument for use with glob().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:fileArgument  Single raw filespec passed from :command -nargs=+
"		    -complete=file ... <q-args>
"* RETURN VALUES:
"   Fileglob with unescaped spaces.
"******************************************************************************
    return substitute(a:fileArgument, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\ ', ' ', 'g')
endfunction
function! ingo#cmdargs#file#SplitAndUnescape( fileArguments )
"******************************************************************************
"* PURPOSE:
"   Split <q-args> filespec arguments into a list of elements, which can then be
"   used with glob().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:fileArguments Raw filespecs passed from :command -nargs=+ -complete=file
"		    ... <q-args>
"* RETURN VALUES:
"   List of fileglobs with unescaped spaces.
"   Note: If the file arguments can start with optional ++opt +cmd file options
"   and commands, these must be re-escaped (after extracting them via
"   ingo#cmdargs#file#FilterFileOptionsAndCommands()) for use in another Ex command:
"	escape(l:fileOptionsAndCommands, '\ ')
"******************************************************************************
    return map(split(a:fileArguments, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\s\+'), 'ingo#cmdargs#file#Unescape(v:val)')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
