" ingo/cmdargs/file.vim: Functions for handling file arguments to commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:fileOptionsExpr = '++\%(ff\|fileformat\|enc\|encoding\|bin\|binary\|nobin\|nobinary\|bad\|edit\)\%(=\S*\)\?'

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
    \       '\%(' . s:fileOptionsExpr . '\s\+\)*' .
    \	    '\%(+.\{-}\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<! \s*\)\?' .
    \   '\)\(.*\)$'
    \)[1:2]
endfunction


function! ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine( fileOptionsAndCommands )
    " cmdline-special symbols (%, #, <) and backslashes may have been escaped
    " already. These escapings must not be doubled, so unescape them first, so
    " that cmdline-special symbols stand on their own, and a double backslash
    " remains as it was passed.
    return join(map(copy(a:fileOptionsAndCommands), "escape(ingo#escape#Unescape(v:val, '%#<\\'), '\\ ')"))
endfunction
function! ingo#cmdargs#file#FilterFileOptions( fileglobs )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt file options that can be given to :write and
"   :saveas.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   (Potentially) removes options from a:fileglobs.
"* INPUTS:
"   a:fileglobs Raw list of file patterns. To get this from a <q-args> string,
"		use ingo#cmdargs#file#SplitAndUnescape().
"* RETURN VALUES:
"   [a:fileglobs, fileOptions]	First element is the passed list, with any file
"   options removed. Second element is a List containing all removed file
"   options.
"   Note: If the file arguments were obtained through
"   ingo#cmdargs#file#SplitAndUnescape(), these must be re-escaped for use
"   in another Ex command via
"   ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(). Or just
"   use ingo#cmdargs#file#FilterFileOptionsToEscaped().
"*******************************************************************************
    return [a:fileglobs, ingo#list#split#RemoveFromStartWhilePredicate(a:fileglobs, 'v:val =~# ' . string('^' . s:fileOptionsExpr . '$'))]
endfunction
function! ingo#cmdargs#file#FilterFileOptionsToEscaped( fileglobs )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt file options that can be given to :write and
"   :saveas.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   (Potentially) removes options from a:fileglobs.
"* INPUTS:
"   a:fileglobs Raw list of file patterns. To get this from a <q-args> string,
"		use ingo#cmdargs#file#SplitAndUnescape().
"* RETURN VALUES:
"   [a:fileglobs, exFileOptions]    First element is the passed list, with any file
"   options removed. Second element is a String with all removed file
"   options joined together and escaped for use in an Ex command.
"*******************************************************************************
    let [l:fileglobs, l:fileOptions] = ingo#cmdargs#file#FilterFileOptions(a:fileglobs)
    return [l:fileglobs, (empty(l:fileOptions) ? '' : ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(l:fileOptions))]
endfunction
function! ingo#cmdargs#file#FilterFileOptionsAndCommands( fileglobs )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt +cmd file options and command that can be given
"   to :edit, :split, etc.
"
"   (In Vim 7.2,) options and commands can only appear at the beginning of the
"   file list; there can be multiple options, followed by only one command. They
"   are only applied to the first (opened) file, not to any other passed file.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   (Potentially) removes options and commands from a:fileglobs.
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
"   in another Ex command via
"   ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(). Or just
"   use ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped().
"*******************************************************************************
    let [l:fileglobs, l:fileOptionsAndCommands] = ingo#cmdargs#file#FilterFileOptions(a:fileglobs)

    if get(l:fileglobs, 0, '') =~# '^++\@!'
	call add(l:fileOptionsAndCommands, remove(l:fileglobs, 0))
    endif

    return [l:fileglobs, l:fileOptionsAndCommands]
endfunction
function! ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped( fileglobs )
"*******************************************************************************
"* PURPOSE:
"   Strip off the optional ++opt +cmd file options and command that can be given
"   to :edit, :split, etc.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   (Potentially) removes options and commands from a:fileglobs.
"* INPUTS:
"   a:fileglobs Raw list of file patterns. To get this from a <q-args> string,
"		use ingo#cmdargs#file#SplitAndUnescape(). Or alternatively
"		use ingo#cmdargs#file#FilterEscapedFileOptionsAndCommands().
"* RETURN VALUES:
"   [a:fileglobs, exFileOptionsAndCommands]	First element is the passed
"   list, with any file options and commands removed. Second element is a String with all removed file
"   options joined together and escaped for use in an Ex command.
"*******************************************************************************
    let [l:fileglobs, l:fileOptionsAndCommands] = ingo#cmdargs#file#FilterFileOptionsAndCommands(a:fileglobs)
    return [l:fileglobs, (empty(l:fileOptionsAndCommands) ? '' : ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(l:fileOptionsAndCommands))]
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
"   and commands, these can be extracted via
"   ingo#cmdargs#file#FilterFileOptionsAndCommands().
"******************************************************************************
    return map(split(a:fileArguments, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\s\+'), 'ingo#cmdargs#file#Unescape(v:val)')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
