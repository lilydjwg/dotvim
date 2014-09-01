" ingo/compat/shellcommand.vim: Escaping of Windows shell commands.
"
" DEPENDENCIES:
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.001	21-Jan-2014	file creation from ingo/escape/shellcommand.vim.

function! ingo#compat#shellcommand#escape( command )
"******************************************************************************
"* PURPOSE:
"   Wrap the entire shell command a:command in double quotes on Windows.
"   This was necessary in Vim versions before 7.3.443 when passing a command to
"   cmd.exe which has arguments that are enclosed in double quotes, e.g.
"	""%SystemRoot%\system32\dir.exe" /B "%ProgramFiles%"".
"
"* EXAMPLE:
"   execute '!' ingo#escape#shellcommand#shellcmdescape(escapings#shellescape($ProgramFiles .
"   '/foobar/foo.exe', 1) . ' ' . escapings#shellescape(args, 1))
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Single shell command, with optional arguments.
"		    The shell command should already have been escaped via
"		    shellescape().
"* RETURN VALUES:
"   Escaped command to be used in a :! command or inside a system() call.
"******************************************************************************
    if ingo#os#IsWinOrDos() && &shellxquote !=# '(' && a:command =~# '"'
	return '"' . a:command . '"'
    endif

    return a:command
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
