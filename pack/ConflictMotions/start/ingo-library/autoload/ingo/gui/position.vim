" ingo/gui/position.vim: Functions for the GVIM position and size.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.001	19-Jul-2013	file creation

function! ingo#gui#position#Get()
    redir => l:winpos
	silent! winpos
    redir END
    return [&lines, &columns, matchstr(l:winpos, '\CX \zs-\?\d\+'), matchstr(l:winpos, '\CY \zs-\?\d\+')]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
