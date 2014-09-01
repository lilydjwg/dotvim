" ingo/selection/position.vim: Functions for getting the positions of the selection.
"
" DEPENDENCIES:
"   - ingo/cursor/move.vim autoload script
"   - ingo/pos.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.003	16-Jun-2014	BUG: Wrong position type causes
"				ingo#selection#position#Get() to be one-off with
"				:set selection=exclusive and when the cursor is
"				after the selection.
"   1.019.002	30-Apr-2014	Use ingo/pos.vim.
"   1.010.001	04-Jul-2013	file creation

function! ingo#selection#position#Get()
"******************************************************************************
"* PURPOSE:
"   Get the start and end position of the current selection. The end position is
"   always _on_ the last selected character, even when 'selection' is
"   "exclusive'.
"* ASSUMPTIONS / PRECONDITIONS:
"   A selection has already been made.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   [[start lnum, start col], [end lnum, end col]]
"******************************************************************************
    if &selection ==# 'exclusive'
	let l:isCursorAfterSelection = ingo#pos#IsOnOrAfter(getpos('.')[1:2], getpos("'>")[1:2])
	let l:endPos = searchpos('\_.\%''>', (l:isCursorAfterSelection ? 'b' : '') . 'cnW', line("'>") + (l:isCursorAfterSelection ? -1 : 0))
	if l:endPos == [0, 0]
	    " This happens with a linewise selection, where col = 0x7FFFFFFF. No
	    " need to adapt that.
	    let l:endPos = getpos("'>")[1:2]
	endif
    else
	let l:endPos = getpos("'>")[1:2]
    endif

    return [getpos("'<")[1:2], l:endPos]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
