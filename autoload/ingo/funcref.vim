" ingo/funcref.vim: Functions for handling Funcrefs.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.001	05-Nov-2013	file creation

function! ingo#funcref#ToString( Funcref )
    return matchstr(string(a:Funcref), "^function('\\zs.*\\ze')$")
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
