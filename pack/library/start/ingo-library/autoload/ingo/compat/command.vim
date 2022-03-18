" ingo/compat/command.vim: Compatibility functions for commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.001	20-Feb-2017	file creation

function! ingo#compat#command#Mods( mods )
"******************************************************************************
"* PURPOSE:
"   Return the command modifiers |<mods>| passed in raw as a:mods.
"   In order to support older Vim versions that don't have this (prior to
"   Vim 7.4.1898), one cannot use <q-mods>; this isn't understood and raises an
"   error. Instead, we can benefit from the fact that the modifiers do not
"   contain special characters, and do the quoting ourselves: '<mods>'. Now we
"   only need to remove the identifer in case it hasn't been understood, and
"   this is what this function is about.
"	-command! Sedit call SpecialEdit(<q-mods>)
"	+command! Sedit call SpecialEdit(ingo#compat#command#Mods('<mods>'))
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   '<mods>'
"* RETURN VALUES:
"   Usable modifiers.
"******************************************************************************
    return (a:mods ==# '<mods>' ? '' : a:mods)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
