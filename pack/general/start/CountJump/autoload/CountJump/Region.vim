" CountJump/Region.vim: Move to borders of a region defined by lines matching a pattern.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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

function! s:SearchInLineMatching( line, Expr, isMatch )
"******************************************************************************
"* PURPOSE:
"   Search for the first (depending on a:isMatch, non-)match with a:Expr in a:line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:line  Line in the current buffer to search. Can be an invalid one.
"   a:Expr	Regular expression to (not) match.
"		Or Funcref to a function that takes a line number and returns
"		the matching byte offset (or -1), just like |match()|.
"   a:isMatch	Flag whether to match.
"* RETURN VALUES:
"   Screen column of the first match, 1 in case of desired non-match, 0 if there
"   is no (non-)match.
"******************************************************************************
    if a:line < 1 || a:line > line('$')
	return 0
    endif

    if type(a:Expr) == type('')
	let l:col = match(getline(a:line), a:Expr)
    elseif type(a:Expr) == 2 " Funcref
	let l:col = call(a:Expr, [a:line])
    else
	throw 'ASSERT: Wrong type, must be either a regexp or a Funcref'
    endif

    if (l:col == -1 && a:isMatch) || (l:col != -1 && ! a:isMatch)
	return 0
    endif

    return (a:isMatch ? l:col + 1 : 1)	" Screen columns start at 1, match returns zero-based index.
endfunction
function! s:SearchForLastLineContinuouslyMatching( startLine, Expr, isMatch, step )
"******************************************************************************
"* PURPOSE:
"   Search for the last line (from a:startLine, using a:step as direction) that
"   matches (or not, according to a:isMatch) a:Expr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None. Does not change the cursor position.
"* INPUTS:
"   a:startLine	Line in the current buffer where the search starts. Can be an
"		invalid one.
"   a:Expr	Regular expression to (not) match.
"		Or Funcref to a function that takes a line number and returns
"		the matching byte offset (or -1), just like |match()|.
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
	let l:col = s:SearchInLineMatching(l:line, a:Expr, a:isMatch)
	if l:col == 0 | break | endif
	let l:foundPosition = [l:line, l:col]
	let l:line += a:step
    endwhile
    return l:foundPosition
endfunction

function! s:TryEvaluateExpr( Expr )
    if type(a:Expr) == 2 " Funcref
	try
	    let l:pattern = call(a:Expr, [])

	    if exists('g:CountJump_TextObjectContext')
		" In an (outer) text object, the current line after the first
		" jump is outside of the matching region. If we picked up the
		" pattern again, it would be wrong. In any case, we should avoid
		" re-querying the pattern. Therefore, save the pattern in the
		" text object context, and recall it from there.
		if ! has_key(g:CountJump_TextObjectContext, 'ExprFuncrefPattern')
		    let g:CountJump_TextObjectContext.ExprFuncrefPattern = l:pattern
		endif
		return g:CountJump_TextObjectContext.ExprFuncrefPattern
	    endif

	    return l:pattern
	catch /^Vim\%((\a\+)\)\=:E119:/ " E119: Not enough arguments for function
	    " This is a type 2 Funcref, to be called with a line number. Keep
	    " it.
	endtry
    endif
    return a:Expr
endfunction

function! CountJump#Region#SearchForRegionEnd( count, Expr, isMatch, step )
"******************************************************************************
"* PURPOSE:
"   Starting from the current line, search for the position where the a:count'th
"   region (as defined by contiguous lines that (don't) match a:Expr) ends.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:count Number of regions to cover.
"   a:Expr	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it.
"		Or Funcref to a function that takes no arguments and returns the
"		regular expression.
"		Or Funcref to a function that takes a line number and returns
"		the matching byte offset (or -1), just like |match()|.
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines.
"   a:step	Increment to go to next line. Use 1 for forward, -1 for backward
"		search.
"* RETURN VALUES:
"   [ line, col ] of the (first match) in the last line that continuously (not)
"   matches, or [0, 0] if no such (non-)match.
"******************************************************************************
    let l:c = a:count
    let l:line = line('.')
    let g:CountJump_MotionContext = {}
    try
	let l:Expr = s:TryEvaluateExpr(a:Expr)

	while 1
	    " Search for the current region's end.
	    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, a:isMatch, a:step)
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
	    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, ! a:isMatch, a:step)
	    if l:line == 0
		return [0, 0]
	    endif

	    let l:line += a:step
	endwhile

	return [l:line, l:col]
    finally
	unlet! g:CountJump_MotionContext
    endtry
endfunction
function! CountJump#Region#JumpToRegionEnd( count, Expr, isMatch, step, isToEndOfLine )
    let l:position = CountJump#Region#SearchForRegionEnd(a:count, a:Expr, a:isMatch, a:step)
    return s:DoJump(l:position, a:isToEndOfLine)
endfunction

function! CountJump#Region#SearchForNextRegion( count, Expr, isMatch, step, isAcrossRegion )
"******************************************************************************
"* PURPOSE:
"   Starting from the current line, search for the position where the a:count'th
"   region (as defined by contiguous lines that (don't) match a:Expr)
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
"   a:Expr	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it.
"		Or Funcref to a function that takes no arguments and returns the
"		regular expression.
"		Or Funcref to a function that takes a line number and returns
"		the matching byte offset (or -1), just like |match()|.
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
    let g:CountJump_MotionContext = {}
    try
	let l:Expr = s:TryEvaluateExpr(a:Expr)

	" Check whether we're currently on the border of a region.
	let l:isInRegion = (s:SearchInLineMatching(l:line, l:Expr, a:isMatch) != 0)
	let l:isNextInRegion = (s:SearchInLineMatching((l:line + a:step), l:Expr, a:isMatch) != 0)
"****D echomsg '**** in region:' (l:isInRegion ? 'current' : '') (l:isNextInRegion ? 'next' : '')
	if l:isInRegion
	    if l:isNextInRegion
		" We're inside a region; search for the current region's end.
		let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, a:isMatch, a:step)
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
	    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, ! a:isMatch, a:step)
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
		    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, a:isMatch, a:step)
		    if l:line == 0
			return [0, 0]
		    endif
		else
		    " Check whether another region starts at the current line.
		    let l:col = s:SearchInLineMatching(l:line, l:Expr, a:isMatch)
		    if l:col == 0
			return [0, 0]
		    endif
		endif

		break
	    endif

	    " Otherwise, we're not done; skip over the next region.
	    let [l:line, l:col] = s:SearchForLastLineContinuouslyMatching(l:line, l:Expr, a:isMatch, a:step)
	    if l:line == 0
		return [0, 0]
	    endif
	    let l:line += a:step
	endwhile

	return [l:line, l:col]
    finally
	unlet! g:CountJump_MotionContext
    endtry
endfunction
function! CountJump#Region#JumpToNextRegion( count, Expr, isMatch, step, isAcrossRegion, isToEndOfLine )
    let l:position = CountJump#Region#SearchForNextRegion(a:count, a:Expr, a:isMatch, a:step, a:isAcrossRegion)
    return s:DoJump(l:position, a:isToEndOfLine)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
