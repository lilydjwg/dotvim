" ingo/window/special.vim: Functions for dealing with special windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.003	28-Jan-2016	ENH: Make
"				ingo#window#special#SaveSpecialWindowSize()
"				return sum of special windows' widths and sum of
"				special windows' heights.
"   1.025.002	26-Jan-2016	ENH: Enable customization of
"				ingo#window#special#IsSpecialWindow() via
"				g:IngoLibrary_SpecialWindowPredicates.
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim

function! ingo#window#special#IsSpecialWindow( ... )
"******************************************************************************
"* PURPOSE:
"   Check whether the current / passed window is special; special windows are
"   preview, quickfix (and location lists, which is also of type 'quickfix').
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:winnr Optional window number.
"   The check can be customized via g:IngoLibrary_SpecialWindowPredicates, which
"   takes a List of Expressions or Funcrefs that are passed the window number,
"   and which should return a boolean flag. If any predicate is true, the window
"   is deemed special.
"* RETURN VALUES:
"   1 if special; else 0.
"******************************************************************************
    let l:winnr = (a:0 > 0 ? a:1 : winnr())
    return getwinvar(l:winnr, '&previewwindow') || getwinvar(l:winnr, '&buftype') ==# 'quickfix' ||
    \   (exists('g:IngoLibrary_SpecialWindowPredicates') && ! empty(
    \       filter(
    \           map(copy(g:IngoLibrary_SpecialWindowPredicates), 'ingo#actions#EvaluateWithValOrFunc(v:val, l:winnr)'),
    \           '!! v:val'
    \       )
    \   ))
endfunction
function! ingo#window#special#SaveSpecialWindowSize()
"******************************************************************************
"* PURPOSE:
"   Calculate widths and heights of visible special windows, and store those for
"   later restoration.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Stores window numbers of special windows, and their current widths and
"   heights.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   [sum of special windows' widths, sum of special windows' heights]
"******************************************************************************
    let s:specialWindowSizes = {}
    let [l:specialWidths, l:specialHeights] = [0, 0]
    for l:w in range(1, winnr('$'))
	if ingo#window#special#IsSpecialWindow(l:w)
	    let [l:width, l:height] = [winwidth(l:w), winheight(l:w)]
	    let s:specialWindowSizes[l:w] = [l:width, l:height]

	    let l:specialWidths += l:width
	    let l:specialHeights += l:height
	endif
    endfor
    return [l:specialWidths, l:specialHeights]
endfunction
function! ingo#window#special#RestoreSpecialWindowSize()
    for l:w in keys(s:specialWindowSizes)
	execute 'vert' l:w . 'resize' s:specialWindowSizes[l:w][0]
	execute        l:w . 'resize' s:specialWindowSizes[l:w][1]
    endfor
endfunction

function! ingo#window#special#HasDiffWindow()
    let l:diffedWinNrs = filter( range(1, winnr('$')), 'getwinvar(v:val, "&diff")' )
    return ! empty(l:diffedWinNrs)
endfunction
function! ingo#window#special#HasOtherDiffWindow()
    let l:winNrs = filter(range(1, winnr('$')), 'v:val != ' . winnr())
    let l:diffedWinNrs = filter(l:winNrs, 'getwinvar(v:val, "&diff")')
    return ! empty(l:diffedWinNrs)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
