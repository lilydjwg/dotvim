" ingo/window/special.vim: Functions for dealing with special windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim

" Special windows are preview, quickfix (and location lists, which is also of
" type 'quickfix').
function! ingo#window#special#IsSpecialWindow( ... )
    let l:winnr = (a:0 > 0 ? a:1 : winnr())
    return getwinvar(l:winnr, '&previewwindow') || getwinvar(l:winnr, '&buftype') ==# 'quickfix'
endfunction
function! ingo#window#special#SaveSpecialWindowSize()
    let s:specialWindowSizes = {}
    for l:w in range(1, winnr('$'))
	if ingo#window#special#IsSpecialWindow(l:w)
	    let s:specialWindowSizes[l:w] = [winwidth(l:w), winheight(l:w)]
	endif
    endfor
endfunction
function! ingo#window#special#RestoreSpecialWindowSize()
    for l:w in keys(s:specialWindowSizes)
	execute 'vert' l:w . 'resize' s:specialWindowSizes[l:w][0]
	execute        l:w . 'resize' s:specialWindowSizes[l:w][1]
    endfor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
