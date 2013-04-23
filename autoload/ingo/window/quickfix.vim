" ingo/window/quickfix.vim: Functions for the quickfix window.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	08-Apr-2013	file creation from autoload/ingowindow.vim

function! ingo#window#quickfix#IsQuickfixList( ... )
"******************************************************************************
"* PURPOSE:
"   Check whether the current window is the quickfix window or a location list.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   determineType   Flag whether it should also be attempted to determine the
"		    type (global quickfix / local location list).
"* RETURN VALUES:
"   Boolean when no a:determineType is given. Else:
"   1 if the current window is the quickfix window.
"   2 if the current window is a location list window.
"   0 for any other window.
"******************************************************************************
    if &buftype !=# 'quickfix'
	return 0
    elseif a:0
	" Try to determine the type; this heuristic only fails when the location
	" list exists but is empty.
	return (empty(getloclist(0)) ? 1 : 2)
    else
	return 1
    endif
endfunction
function! ingo#window#quickfix#ParseFileFromQuickfixList()
    return (ingo#window#quickfix#IsQuickfixList() ? matchstr(getline('.'), '^.\{-}\ze|') : '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
