" Region.vim: Move to borders of a region defined by lines matching a pattern. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.41.009	13-Jun-2011	FIX: Directly ring the bell to avoid problems
"				when running under :silent!. 
"   1.40.008	20-Dec-2010	Jump functions again return position (and
"				actual, corrected one for a:isToEndOfLine).
"				Though the position is not used for motions, it
"				is necessary for text objects to differentiate
"				between "already at the begin/end position" and
"				"no such position". 
"   1.30.007	19-Dec-2010	Shuffling of responsibilities in
"				CountJump#JumpFunc():
"				CountJump#Region#JumpToRegionEnd() and
"				CountJump#Region#JumpToNextRegion() now need to
"				beep themselves if no match is found, but do not
"				return the position any more. 
"				Added a:isToEndOfLine argument to
"				CountJump#Region#JumpToRegionEnd() and
"				CountJump#Region#JumpToNextRegion(), which is
"				useful for operator-pending and characterwise
"				visual mode mappings; the entire last line will
"				then be operated on / selected. 
"   1.30.006	18-Dec-2010	Moved CountJump#Region#Jump() to CountJump.vim
"				as CountJump#JumpFunc(). It fits there much
"				better because of the similarity to
"				CountJump#CountJump(), and actually has nothing
"				to do with regions. 
"   1.30.005	18-Dec-2010	ENH: Added a:isMatch argument to
"				CountJump#Region#SearchForRegionEnd(),
"				CountJump#Region#JumpToRegionEnd(),
"				CountJump#Region#SearchForNextRegion(),
"				CountJump#Region#JumpToNextRegion(). This allows
"				definition of regions via non-matches, which can
"				be substantially simpler (and faster to match)
"				than coming up with a "negative" regular
"				expression. 
"   1.21.004	03-Aug-2010	FIX: A 2]] jump inside a region (unless last
"				line) jumped like a 1]] jump. The search for
"				next region must not decrease the iteration
"				counter when _not_ searching _across_ the
"				region. 
"   1.20.003	30-Jul-2010	FIX: Removed setting of cursor position. 
"				FIX: CountJump#Region#Jump() with mode "O"
"				didn't add original position to jump list.
"				Simplified conditional. 
"   1.20.002	29-Jul-2010	FIX: Non-match in s:SearchInLineMatching()
"				returned 0; now returning 1. 
"				FIX: Must decrement count after having searched
"				for the end of the region at the cursor
"				position. 
"				Split cursor movement from
"				CountJump#Region#SearchForRegionEnd() and
"				CountJump#Region#SearchForNextRegion() into
"				separate #JumpTo...() functions. 
"	001	21-Jul-2010	file creation

function! s:DoJump( position, isToEndOfLine )
    if a:position == [0, 0]
	" Ring the bell to indicate that no further match exists. 
	execute "normal! \<C-\>\<C-n>\<Esc>"
    else
	call setpos('.', [0] + a:position + [0])
	if a:isToEndOfLine
	    normal! $zv
	    return getpos('.')[1:2]
	else
	    normal! zv
	endif
    endif
    
    return a:position
endfunction

function! s:SearchInLineMatching( line, pattern, isMatch )
"******************************************************************************
"* PURPOSE:
"   Search for the first (depending on a:isMatch, non-)match with a:pattern in a:line. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. 
"* INPUTS:
"   a:line  Line in the current buffer to search. Can be an invalid one. 
"   a:pattern	Regular expression to (not) match. 
"   a:isMatch	Flag whether to match. 
"* RETURN VALUES: 
"   Screen column of the first match, 1 in case of desired non-match, 0 if there
"   is no (non-)match. 
"******************************************************************************
    if a:line < 1 || a:line > line('$')
	return 0
    endif

    let l:col = match(getline(a:line), a:pattern)
    if (l:col == -1 && a:isMatch) || (l:col != -1 && ! a:isMatch)
	return 0
    endif

    return (a:isMatch ? l:col + 1 : 1)	" Screen columns start at 1, match returns zero-based index. 
endfunction
function! s:SearchForLastLineContinuouslyMatching( startLine, pattern, isMatch, step )
"******************************************************************************
"* PURPOSE:
"   Search for the last line (from a:startLine, using a:step as direction) that
"   matches (or not, according to a:isMatch) a:pattern. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. Does not change the cursor position. 
"* INPUTS:
"   a:startLine	Line in the current buffer where the search starts. Can be an
"		invalid one. 
"   a:pattern	Regular expression to (not) match. 
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines. 
"   a:step	Increment to go to next line. Use 1 for forward, -1 for backward
"		search. 
"* RETURN VALUES: 
"   [ line, col ] of the (first match) in the last line that continuously (not)
"   matches, or [0, 0] if no such (non-)match. 
"******************************************************************************
    let l:line = a:startLine
    let l:foundPosition = [0, 0]
    while 1
	let l:col = s:SearchInLineMatching(l:line, a:pattern, a:isMatch)
	if l:col == 0 | break | endif
	let l:foundPosition = [l:line, l:col]
	let l:line += a:step
    endwhile
    return l:foundPosition
endfunction

function! CountJump#Region#SearchForRegionEnd( count, pattern, isMatch, step )
"******************************************************************************
"* PURPOSE:
"   Starting from the current line, search for the position where the a:count'th
"   region (as defined by contiguous lines that (don't) match a:pattern) ends. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. 
"* INPUTS:
"   a:count Number of regions to cover. 
"   a:pattern	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it. 
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines. 
"   a:step	Increment to go to next line. Use 1 for forward, -1 for backward
"		search. 
"* RETURN VALUES: 
"   [ line, col ] of the (first match) in the last line that continuously (not)
"   matches, or [0, 0] if no such (non-)match. 
"******************************************************************************
    let l:c = a:count
    let l:line = line('.')
    while 1
	" Search for the current region's end. 
	let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, a:isMatch, a:step)
	if l:line == 0
	    return [0, 0]
	endif

	" If this is the last region to be found, we're done. 
	let l:c -= 1
	if l:c == 0
	    break
	endif

	" Otherwise, search for the next region's start. 
	let l:line += a:step
	let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, ! a:isMatch, a:step)
	if l:line == 0
	    return [0, 0]
	endif

	let l:line += a:step
    endwhile

    return [l:line, l:col]
endfunction
function! CountJump#Region#JumpToRegionEnd( count, pattern, isMatch, step, isToEndOfLine )
    let l:position = CountJump#Region#SearchForRegionEnd(a:count, a:pattern, a:isMatch, a:step)
    return s:DoJump(l:position, a:isToEndOfLine)
endfunction

function! CountJump#Region#SearchForNextRegion( count, pattern, isMatch, step, isAcrossRegion )
"******************************************************************************
"* PURPOSE:
"   Starting from the current line, search for the position where the a:count'th
"   region (as defined by contiguous lines that (don't) match a:pattern)
"   begins/ends. 
"   If the current line is inside the border of a region, jumps to the next one.
"   If it is actually inside a region, jumps to the current region's border. 
"   This makes it work like the built-in motions: [[, ]], etc. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   Moves cursor to match if it exists. 
"* INPUTS:
"   a:count Number of regions to cover. 
"   a:pattern	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it. 
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines. 
"   a:step	Increment to go to next line. Use 1 for forward, -1 for backward
"		search. 
"   a:isAcrossRegion	Flag whether to search across the region for the last
"			(vs. first) line belonging to the region (while moving
"			in a:step direction). 
"* RETURN VALUES: 
"   [ line, col ] of the (first match) in the last line that continuously (not)
"   matches, or [0, 0] if no such (non-)match. 
"******************************************************************************
    let l:c = a:count
    let l:isDone = 0
    let l:line = line('.')

    " Check whether we're currently on the border of a region. 
    let l:isInRegion = (s:SearchInLineMatching(l:line, a:pattern, a:isMatch) != 0)
    let l:isNextInRegion = (s:SearchInLineMatching((l:line + a:step), a:pattern, a:isMatch) != 0)
"****D echomsg '**** in region:' (l:isInRegion ? 'current' : '') (l:isNextInRegion ? 'next' : '')
    if l:isInRegion
	if l:isNextInRegion
	    " We're inside a region; search for the current region's end. 
	    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, a:isMatch, a:step)
	    if a:isAcrossRegion
		if l:c == 1
		    " We're done already! 
		    let l:isDone = 1
		else
		    " We've moved to the border, resume the search for following
		    " regions...
		    let l:c = max([l:c - 1, 1])
		    " ...from the next line so that we move out of the current
		    " region. 
		    let l:line += a:step
		endif
	    else
		" We're on the border, start the search from the next line so
		" that we move out of the current region. 
		let l:line += a:step
	    endif
	else
	    " We're on the border, start the search from the next line so that we
	    " move out of the current region. 
	    let l:line += a:step
	endif
    endif

"****D echomsg '**** starting iteration on line' l:line
    while ! l:isDone
	" Search for the next region's start. 
	let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, ! a:isMatch, a:step)
	if l:line == 0
	    return [0, 0]
	endif
	let l:line += a:step

	" If this is the last region to be found, we're almost done. 
"****D echomsg '**** iteration' l:c 'on line' l:line
	let l:c -= 1
	if l:c == 0
	    if a:isAcrossRegion
		" Search for the current region's end. 
		let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, a:isMatch, a:step)
		if l:line == 0
		    return [0, 0]
		endif
	    else
		" Check whether another region starts at the current line. 
		let l:col = s:SearchInLineMatching(l:line, a:pattern, a:isMatch)
		if l:col == 0
		    return [0, 0]
		endif
	    endif

	    break
	endif

	" Otherwise, we're not done; skip over the next region. 
	let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, a:pattern, a:isMatch, a:step)
	if l:line == 0
	    return [0, 0]
	endif
	let l:line += a:step
    endwhile

    return [l:line, l:col]
endfunction
function! CountJump#Region#JumpToNextRegion( count, pattern, isMatch, step, isAcrossRegion, isToEndOfLine )
    let l:position = CountJump#Region#SearchForNextRegion(a:count, a:pattern, a:isMatch, a:step, a:isAcrossRegion)
    return s:DoJump(l:position, a:isToEndOfLine)
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
