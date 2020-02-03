" ingo/window.vim: Functions for dealing with windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#window#GotoNext( direction, ... )
"******************************************************************************
"* PURPOSE:
"   Go to the next window in a:direction.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Activates another window.
"* INPUTS:
"   a:direction One of 'j', 'k', 'h', 'l'.
"   a:count     Number of windows to move (default 1).
"* RETURN VALUES:
"   1 if the move was successful, 0 if there's no [a:count] window[s] in that
"   direction.
"******************************************************************************
    let l:prevWinNr = winnr()
    execute (a:0 > 0 ? a:1 : '') . 'wincmd' a:direction
    return winnr() != l:prevWinNr
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
