" ingo/format/columns.vim: Functions for formatting in multiple columns.
"
" DEPENDENCIES:
"   - ingo/strdisplaywidth.vim autoload script
"   - ingo/strdisplaywidth/pad.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	11-Aug-2016	file creation

function! ingo#format#columns#Distribute( strings, ... )
"******************************************************************************
"* PURPOSE:
"   Distribute a:strings to a number of (equally sized) columns, fitting a
"   maximum width of a:width / &columns.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strings:  List of strings.
"   a:alignment One of "left", "middle", "right"; default is "left".
"   a:width     Maximum width of all columns taken together.
"   a:columnSeparatorWidth  Width of the column separator with which the
"			    returned inner List elements will be join()ed;
"			    default 1.
"* RETURN VALUES:
"   List of [[c1s1, c2s1, ...], [c1s2, c2s2, ...], ...]
"******************************************************************************
    let l:PadFunction = function('ingo#strdisplaywidth#pad#' . {'left': 'Right', 'middle': 'Middle', 'right': 'Left'}[a:0 ? a:1 : 'left'])
    let l:columnSeparatorWidth = (a:0 >= 3 ? a:3 : 1)
    let l:maxWidth = ingo#strdisplaywidth#GetMinMax(a:strings)[1]
    let l:colNum = (a:0 >= 2 ? a:2 : &columns) / (l:maxWidth + l:columnSeparatorWidth)
    let l:rowNum = len(a:strings) / l:colNum + (len(a:strings) % l:colNum == 0 ? 0 : 1)

    "let l:result = repeat([[]], l:rowNum)  " Unfortunately duplicates the same empty List.
    let l:result = []
    for l:i in range(l:rowNum)
	call add(l:result, [])
    endfor

    let l:i = 0
    for l:string in a:strings
	if l:i >= l:rowNum
	    let l:i = 0
	endif

	call add(l:result[l:i], call(l:PadFunction, [l:string, l:maxWidth]))
	let l:i += 1
    endfor

    return l:result
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
