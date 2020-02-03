" ingo/folds.vim: Functions for dealing with folds.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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
function! ingo#folds#LastVisibleLine( lnum, direction )
"******************************************************************************
"* PURPOSE:
"   Determine the line number of the last visible (i.e. not folded) line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on.
"   a:direction -1 for upward, 1 for downward relative movement
"* RETURN VALUES:
"   line number, of -1 if there is no more visible line in that direction of the
"   buffer.
"******************************************************************************
    let l:lnum = ingo#folds#NextVisibleLine(a:lnum, a:direction)
    if l:lnum == -1
	return l:lnum
    endif

    while l:lnum > 0 && l:lnum <= line('$')
	if foldclosed(l:lnum) != -1
	    break
	endif

	let l:lnum += a:direction
    endwhile

    return l:lnum - a:direction
endfunction
function! ingo#folds#NextClosedLine( lnum, direction )
"******************************************************************************
"* PURPOSE:
"   Determine the line number of the next closed (i.e. folded) line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on. When this one is folded, it
"           is returned.
"   a:direction -1 for upward, 1 for downward relative movement
"* RETURN VALUES:
"   line number, of -1 if there is no more folded line in that direction of the
"   buffer.
"******************************************************************************
    let l:lnum = a:lnum

    while l:lnum > 0 && l:lnum <= line('$')
	if foldclosed(l:lnum) != -1
	    return l:lnum
	endif

	let l:lnum += a:direction
    endwhile

    return -1
endfunction
function! ingo#folds#LastClosedLine( lnum, direction )
"******************************************************************************
"* PURPOSE:
"   Determine the line number of the last closed (i.e. folded) line. Unlike
"   foldclosedend(), considers multiple adjacent closed folds as one unit.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on.
"   a:direction -1 for upward, 1 for downward relative movement
"* RETURN VALUES:
"   line number, of -1 if there is no more folded line in that direction of the
"   buffer.
"******************************************************************************
    let l:lnum = ingo#folds#NextClosedLine(a:lnum, a:direction)
    if l:lnum == -1
	return l:lnum
    endif

    while l:lnum > 0 && l:lnum <= line('$')
	let l:borderLnum = (a:direction < 0 ? foldclosed(l:lnum) : foldclosedend(l:lnum))
	if l:borderLnum == -1
	    break
	endif

	let l:lnum = l:borderLnum + a:direction
    endwhile

    return l:lnum - a:direction
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


function! ingo#folds#FoldedLines( startLine, endLine )
"******************************************************************************
"* PURPOSE:
"   Determine the number of lines in the passed range that lie hidden in a
"   closed fold; that is, everything but the first line of a closed fold.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startLnum First line of the range.
"   a:endLnum   Last line of the range.
"* RETURN VALUES:
"   Returns [ number of folds in range, number of folded away (i.e. invisible)
"   lines ]. Sum both values to get the total number of lines in a fold in the
"   passed range.
"******************************************************************************
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

function! ingo#folds#GetOpenFoldRange( lnum )
"******************************************************************************
"* PURPOSE:
"   Determine the range of the open fold around a:lnum.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to be considered.
"* RETURN VALUES:
"   [startLnum, endLnum] of the fold. If the line is fully in closed fold(s) or
"   not inside a fold at all, returns the entire range of the buffer.
"******************************************************************************
    if foldlevel(a:lnum) == 0
	" No fold at that line.
	return [1, line('$')]
    endif

    let l:save_view = winsaveview()
    try
	let [l:originalClosedStartLnum, l:originalClosedEndLnum] = [foldclosed(a:lnum), foldclosedend(a:lnum)]

	execute a:lnum . 'foldclose'
	let l:isAtBeginningOfCurrentFold = (foldclosed(a:lnum) == a:lnum)

	if foldclosed(a:lnum) == l:originalClosedStartLnum && foldclosedend(a:lnum) == l:originalClosedEndLnum
	    " The :foldclose didn't have any noticeable effect; either the line
	    " is on a toplevel closed fold, or on an nested open, same-size fold
	    " (which we'll leave closed as a side effect).
	else
	    execute a:lnum . 'foldopen'
	endif

	if l:isAtBeginningOfCurrentFold
	    " [z would jump to the beginning of the previous open fold, and
	    " we've already determined the start of the open fold, anyway.
	    let l:startLnum = a:lnum
	else
	    silent! execute a:lnum . 'normal! [z'
	    let l:startLnum = line('.')
	endif

	silent! execute a:lnum . 'normal! ]z'
	let l:endLnum = line('.')
	if l:endLnum == l:startLnum
	    " The cursor didn't move; there's no open fold, so return the whole
	    " buffer.
	    return [1, line('$')]
	endif

	return [l:startLnum, l:endLnum]
    finally
	call winrestview(l:save_view)
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
