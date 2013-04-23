" ingo/system.vim: Functions for invoking shell commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.003.001	22-Mar-2013	file creation

function! ingo#system#Chomped( ... )
"******************************************************************************
"* PURPOSE:
"   Wrapper around system() that strips off trailing newline(s).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   As |system()|
"* RETURN VALUES:
"   Output of the shell command, without trailing newline(s).
"******************************************************************************
    return substitute(call('system', a:000), '\n\+$', '', '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
