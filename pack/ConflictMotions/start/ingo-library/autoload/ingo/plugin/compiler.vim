" ingo/plugin/compiler.vim: Functions for compiler plugins.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.001	21-Jan-2014	file creation

function! ingo#plugin#compiler#CompilerSet( optionname, expr )
    execute 'CompilerSet' a:optionname . '=' . escape(a:expr, ' "|\')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
