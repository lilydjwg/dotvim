" ingo/escape/command.vim: Additional escapings of Ex commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.012.001	09-Aug-2013	file creation

function! ingo#escape#command#mapescape( command )
"******************************************************************************
"* PURPOSE:
"   Escape the Ex command a:command for use in the right-hand side of a mapping.
"   If you want to redefine an existing mapping, use ingo#compat#maparg()
"   instead; it already returns this in the correct format.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:command   Ex command(s).
"* RETURN VALUES:
"   a:command for use in a :map command.
"******************************************************************************
    let l:command = a:command
    let l:command = substitute(l:command, '<', '<lt>', 'g')     " '<' may introduce a special-notation key; better escape them all.
    let l:command = substitute(l:command, '|', '<Bar>', 'g')    " '|' must be escaped, or the map command will end prematurely.
    return l:command
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
