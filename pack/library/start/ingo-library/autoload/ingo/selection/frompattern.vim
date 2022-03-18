" ingo/selection/frompattern.vim: Functions to select around the cursor based on a regexp.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.003	01-Oct-2014	ENH: Make
"				ingo#selection#frompattern#GetPositions()
"				automatically convert \%# in the passed
"				a:pattern to the hard-coded cursor column.
"   1.012.002	07-Aug-2013	CHG: Change return value format of
"				ingo#selection#frompattern#GetPositions() to
"				better match the arguments of functions like
"				ingo#text#Get().
"   1.011.001	23-Jul-2013	file creation from ingointegration.vim.

function! ingo#selection#frompattern#GetPositions( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Similar to <cword>, get the selection under / after the cursor that matches
"   a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression to match at the cursor position.
"   a:stopline  Optional line number where the search will stop. To get a
"		behavior like <cword>, pass in line('.').
"   a:timeout   Optional timeout when the search will stop.
"* RETURN VALUES:
"   [[startLnum, startCol], [endLnum, endCol]] or [[0, 0], [0, 0]]
"******************************************************************************
    " To match the cursor position itself, the \%# atom cannot be used directly
    " (because of the jumping around); instead, the current cursor column must
    " be hard-coded.
    let l:pattern = substitute(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%#', '\\%' . col('.') . 'c', 'g')

    let l:selection = [[0, 0], [0, 0]]
    let l:save_view = winsaveview()
	let l:endPos = call('searchpos', [l:pattern, 'ceW'] + a:000)
	if l:endPos == [0, 0]
	    return l:selection
	endif

	let l:startPos = call('searchpos', [l:pattern, 'bcnW'] + a:000)
	if l:startPos != [0, 0]
	    let l:selection = [l:startPos, l:endPos]
	endif
    call winrestview(l:save_view)

    return l:selection
endfunction

function! ingo#selection#frompattern#Select( selectMode, pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Similar to <cword>, create a visual selection of the text region under /
"   after the cursor that matches a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates a visual selection if a:pattern matches.
"* INPUTS:
"   a:selectMode    Visual selection mode, one of "v", "V", or "\<C-v>".
"   a:pattern   Regular expression to match at the cursor position.
"   a:stopline  Optional line number where the search will stop. To get a
"		behavior like <cword>, pass in line('.').
"   a:timeout   Optional timeout when the search will stop.
"* RETURN VALUES:
"   1 if a selection was made, 0 if there was no match.
"******************************************************************************
    let [l:startPos, l:endPos] = call('ingo#selection#frompattern#GetPositions', [a:pattern] + a:000)
    if l:startPos == [0, 0]
	return 0
    endif
    call cursor(l:startPos[0], l:startPos[1])
    execute 'normal! zv' . a:selectMode
    call cursor(l:endPos[0], l:endPos[1])
    if &selection ==# 'exclusive'
	normal! l
    endif
    execute "normal! \<Esc>"

    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
