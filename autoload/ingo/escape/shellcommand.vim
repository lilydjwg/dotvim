" ingo/escape/shellcommand.vim: Additional escapings of shell commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.003	21-Jan-2014	Move ingo#escape#shellcommand#shellcmdescape()
"				to ingo#compat#shellcommand#escape(), as it is
"				only required for older Vim versions.
"   1.012.002	09-Aug-2013	Rename file.
"	001	08-Aug-2013	file creation from escapings.vim.

function! ingo#escape#shellcommand#exescape( command )
"*******************************************************************************
"* PURPOSE:
"   Escape a shell command (potentially consisting of multiple commands and
"   including (already quoted) command-line arguments) so that it can be used in
"   Ex commands. For example: 'hostname && ps -ef | grep -e "foo"'.
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Shell command-line.
"
"* RETURN VALUES:
"   Escaped shell command to be passed to the !{cmd} or :r !{cmd} commands.
"*******************************************************************************
    if exists('*fnameescape')
	return join(map(split(a:command, ' '), 'fnameescape(v:val)'), ' ')
    else
	return escape(a:command, '\%#|' )
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
