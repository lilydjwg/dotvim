" ingo/window/adjacent.vim: Functions around windows that are next to each other.
"
" DEPENDENCIES:
"   - ingo/window.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#window#adjacent#FindHorizontal()
"******************************************************************************
"* PURPOSE:
"   Locate the windows that are left and right of the current window. If
"   multiple splits border a window, only that one that would be jumped to based
"   on the cursor position is selected.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   List of window numbers, including the current window.
"******************************************************************************
    return s:Find('h', 'l')
endfunction
function! ingo#window#adjacent#FindVertical()
"******************************************************************************
"* PURPOSE:
"   Locate the windows that are above and below the current window. If multiple
"   splits border a window, only that one that would be jumped to based on the
"   cursor position is selected.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   List of window numbers, including the current window.
"******************************************************************************
    return s:Find('k', 'j')
endfunction
function! s:Find( prevDirection, nextDirection )
    let l:originalWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    let l:save_eventignore = &eventignore
    set eventignore=all
    try
	let l:winNrs = [winnr()]

	while ingo#window#GotoNext(a:prevDirection)
	    call insert(l:winNrs, winnr(), 0)
	endwhile

	execute l:originalWinNr . 'wincmd w'

	while ingo#window#GotoNext(a:nextDirection)
	    call add(l:winNrs, winnr())
	endwhile

	return l:winNrs
    finally
	execute l:previousWinNr . 'wincmd w'
	execute l:originalWinNr . 'wincmd w'

	let &eventignore = l:save_eventignore
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
