" ingo/folds.vim: Functions for dealing with folds.
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

function! s:FoldBorder( lnum, direction )
    let l:foldBorder = (a:direction < 0 ? foldclosed(a:lnum) : foldclosedend(a:lnum))
    return (l:foldBorder == -1 ? a:lnum : l:foldBorder)
endfunction
function! ingo#folds#RelativeWindowLine( lnum, count, direction, ... )
"******************************************************************************
"* PURPOSE:
"   Determine the line number a:count visible (i.e. not folded) lines away from
"   a:lnum, including all lines in closed folds.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on.
"   a:count     Number of visible lines away from a:lnum.
"   a:direction -1 for upward, 1 for downward relative movement of a:count lines
"   a:folddirection for a fold at the target, return the fold start lnum when
"		    -1, or the fold end lnum when 1. Defaults to a:direction,
"		    which amounts to the maximum covered lines, i.e. for upward
"		    movement, the fold start, for downward movement, the fold
"		    end
"* RETURN VALUES:
"   line number, or -1 if the relative line is out of the range of the lines in
"   the buffer.
"******************************************************************************
    let l:lnum = a:lnum
    let l:count = a:count

    while l:count > 0
	let l:lnum = s:FoldBorder(l:lnum, a:direction) + a:direction
	if a:direction < 0 && l:lnum < 1 || a:direction > 0 && l:lnum > line('$')
	    return -1
	endif

	let l:count -= 1
    endwhile

    return s:FoldBorder(l:lnum, (a:0 ? a:1 : a:direction))
endfunction
function! ingo#folds#NextVisibleLine( lnum, direction )
"******************************************************************************
"* PURPOSE:
"   Determine the line number of the next visible (i.e. not folded) line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on. When this one isn't folded,
"	    it is returned.
"   a:direction -1 for upward, 1 for downward relative movement
"* RETURN VALUES:
"   line number, of -1 if there is no more visible line in that direction of the
"   buffer.
"******************************************************************************
    let l:lnum = a:lnum
    while l:lnum > 0 && l:lnum <= line('$')
	let l:borderLnum = (a:direction < 0 ? foldclosed(l:lnum) : foldclosedend(l:lnum))
	if l:borderLnum == -1
	    return l:lnum
	else
	    let l:lnum = l:borderLnum + a:direction
	endif
    endwhile

    return -1
endfunction


function! ingo#folds#GetClosedFolds( startLnum, endLnum )
"******************************************************************************
"* PURPOSE:
"   Determine the ranges of closed folds within the passed range.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startLnum First line of the range.
"   a:endLnum   Last line of the range.
"* RETURN VALUES:
"   List of [foldStartLnum, foldEndLnum] elements.
"******************************************************************************
    let l:folds = []
    let l:lnum = a:startLnum
    while l:lnum <= a:endLnum
	let l:foldEndLnum = foldclosedend(l:lnum)
	if l:foldEndLnum == -1
	    let l:lnum += 1
	else
	    call add(l:folds, [l:lnum, l:foldEndLnum])
	    let l:lnum = l:foldEndLnum + 1
	endif
    endwhile
    return l:folds
endfunction


" Determine the number of lines in the passed range that lie hidden in a closed
" fold; that is, everything but the first line of a closed fold.
" Returns [ number of folds in range, number of folded away (i.e. invisible)
" lines ]. Sum both values to get the total number of lines in a fold in the
" passed range.
function! ingo#folds#FoldedLines( startLine, endLine )
    let l:foldCnt = 0
    let l:foldedAwayLines = 0
    let l:line = a:startLine

    while l:line < a:endLine
	if foldclosed(l:line) == l:line
	    let l:foldCnt += 1
	    let l:foldend = foldclosedend(l:line)
	    let l:foldedAwayLines += (l:foldend > a:endLine ? a:endLine : l:foldend) - l:line
	    let l:line = l:foldend
	endif
	let l:line += 1
    endwhile

    return [ l:foldCnt, l:foldedAwayLines ]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
