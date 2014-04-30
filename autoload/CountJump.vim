" CountJump.vim: Move to a buffer position via repeated jumps (or searches).
"
" DEPENDENCIES:
"   - ingo/motion/helper.vim autoload script (optional)
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.83.019	11-Jan-2014	Factor out special treatment for visual and
"				operator-pending motions to
"				ingo#motion#helper#AdditionalMovement(), but
"				keep internal fallback to keep the dependency to
"				ingo-library optional.
"   1.83.018	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"				FIX: Need to save v:count1 before issuing the
"				normal mode "gv" command.
"   1.81.017	15-Oct-2012	BUG: Wrong variable scope for copied
"				a:isBackward in
"				CountJump#CountSearchWithWrapMessage().
"   1.80.016	18-Sep-2012	Clear any previous wrap message when wrapping is
"				enabled; it's confusing otherwise.
"   1.80.015	17-Sep-2012	FIX: Visual end pattern / jump to end with
"				'selection' set to "exclusive" also requires the
"				special additional treatment of moving one
"				right, like operator-pending mode.
"   1.80.014	15-Sep-2012	Also handle move to the buffer's very last
"				character in operator-pending mode with a
"				pattern to end "O" motion by temporarily setting
"				'virtualedit' to "onemore".
"				Add CountJump#CountJumpFuncWithWrapMessage() /
"				CountJump#CountJumpFunc() to help implement
"				custom motions with only a simple function that
"				performs a single jump. (Used by the
"				SameSyntaxMotion plugin.)
"   1.70.013	17-Aug-2012	ENH: Check for searches wrapping around the
"				buffer and issue a corresponding warning, like
"				the built-in searches do. Though the mappings
"				that can be made with CountJump currently do not
"				use 'wrapscan', other plugins that define their
"				own jump functions and use the
"				CountJump#CountJump() function for it may use
"				it. Create function overloads
"				CountJump#CountJumpWithWrapMessage() and
"				CountJump#CountSearchWithWrapMessage().
"   1.41.012	13-Jun-2011	FIX: Directly ring the bell to avoid problems
"				when running under :silent!.
"   1.30.011	19-Dec-2010	Removed return value of jump position from
"				CountJump#CountJump() and CountJump#JumpFunc();
"				it isn't needed, as these functions are
"				typically used directly in motion mappings.
"				CountJump#JumpFunc() now uses cursor position
"				after invoking jump function, and doesn't
"				require a returned position any more. This is
"				only a special case for CountJump#TextObject,
"				and should not be generally required of a jump
"				function. The jump function is now also expected
"				to beep, so removed that here.
"   1.30.010	18-Dec-2010	Moved CountJump#Region#Jump() here as
"				CountJump#JumpFunc(). It fits here much better
"				because of the similarity to
"				CountJump#CountJump(), and actually has nothing
"				to do with regions.
"   1.20.009	30-Jul-2010	FIX: CountJump#CountJump() with mode "O" didn't
"				add original position to jump list. Simplified
"				conditional.
"   1.10.008	15-Jul-2010	Changed behavior if there aren't [count]
"				matches: Instead of jumping to the last
"				available match (and ringing the bell), the
"				cursor stays at the original position, like with
"				the old vi-compatible motions.
"				ENH: Only adding to jump list if there actually
"				is a match. This is like the built-in Vim
"				motions work.
"   1.00.007	22-Jun-2010	Added special mode 'O' for
"				CountJump#CountJump() with special correction
"				for a pattern to end in operator-pending mode.
"				Reviewed for use in operator-pending mode.
"	006	03-Oct-2009	Now returning [lnum, col] like searchpos(), not
"				just line number.
"	005	02-Oct-2009	CountJump#CountSearch() now handles 'c' search()
"				flag; it is cleared on subsequent iterations to
"				avoid staying put at the current match.
"	004	14-Feb-2009	Renamed from 'custommotion.vim' to
"				'CountJump.vim' and split off motion and
"				text object parts.
"	003	13-Feb-2009	Added functionality to create inner/outer text
"				objects delimited by the same begin and end
"				patterns.
"	002	13-Feb-2009	Now also allowing end match for the
"				patternToEnd.
"	001	12-Feb-2009	file creation

function! s:WrapMessage( searchName, isBackward )
    if &shortmess !~# 's'
	let v:warningmsg = a:searchName . ' ' . (a:isBackward ? 'hit TOP, continuing at BOTTOM' : 'hit BOTTOM, continuing at TOP')
	echohl WarningMsg
	echomsg v:warningmsg
	echohl None
    endif
endfunction
function! CountJump#CountSearchWithWrapMessage( count, searchName, searchArguments )
"*******************************************************************************
"* PURPOSE:
"   Search for the a:count'th occurrence of the passed search() pattern and
"   arguments.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Jumps to the a:count'th occurrence and opens any closed folds there.
"   If the pattern doesn't match (a:count times), a beep is emitted.
"
"* INPUTS:
"   a:count Number of occurrence to jump to.
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". When empty, no wrap message is issued.
"   a:searchArguments	Arguments to search() as a List [{pattern}, {flags}, ...]
"
"* RETURN VALUES:
"   List with the line and column position, or [0, 0], like searchpos().
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:searchArguments = copy(a:searchArguments)
    let l:isWrapped = 0
    let l:isBackward = (get(a:searchArguments, 1, '') =~# 'b')
    let [l:prevLine, l:prevCol] = [line('.'), col('.')]

    for l:i in range(1, a:count)
	let l:matchPosition = call('searchpos', l:searchArguments)
	if l:matchPosition == [0, 0]
	    if l:i > 1
		" (Due to the count,) we've already moved to an intermediate
		" match. Undo that to behave like the old vi-compatible
		" motions. (Only the ]s motion has different semantics; it obeys
		" the 'wrapscan' setting and stays at the last possible match if
		" the setting is off.)
		call winrestview(l:save_view)
	    endif

	    " Ring the bell to indicate that no further match exists.
	    execute "normal! \<C-\>\<C-n>\<Esc>"

	    return l:matchPosition
	endif

	if len(l:searchArguments) > 1 && l:i == 1
	    " In case the search accepts a match at the cursor position
	    " (i.e. search(..., 'c')), the flag must only be active on the very
	    " first iteration; otherwise, all subsequent iterations will just
	    " stay put at the current match.
	    let l:searchArguments[1] = substitute(l:searchArguments[1], '\Cc', '', 'g')
	endif

	" Note: No need to check s:searchArguments and 'wrapscan'; the wrapping
	" can only occur if 'wrapscan' is actually on.
	if ! l:isBackward && (l:prevLine > l:matchPosition[0] || l:prevLine == l:matchPosition[0] && l:prevCol >= l:matchPosition[1])
	    let l:isWrapped = 1
	elseif l:isBackward && (l:prevLine < l:matchPosition[0] || l:prevLine == l:matchPosition[0] && l:prevCol <= l:matchPosition[1])
	    let l:isWrapped = 1
	endif
	let [l:prevLine, l:prevCol] = l:matchPosition
    endfor

    " Open the fold at the final search result. This makes the search work like
    " the built-in motions, and avoids that some visual selections get stuck at
    " a match inside a closed fold.
    normal! zv

    if ! empty(a:searchName)
	if l:isWrapped
	    redraw
	    call s:WrapMessage(a:searchName, l:isBackward)
	else
	    " We need to clear any previous wrap message; it's confusing
	    " otherwise. /pattern searches do not have that problem, as they
	    " echo the search pattern.
	    echo
	endif
    endif

    return l:matchPosition
endfunction
function! CountJump#CountSearch( count, searchArguments )
    return CountJump#CountSearchWithWrapMessage(a:count, '', a:searchArguments)
endfunction
silent! call ingo#motion#helper#DoesNotExist()	" Execute a function to force autoload.
if exists('*ingo#motion#helper#AdditionalMovement')
function! s:AdditionalMovement( isSpecialLastLineTreatment )
    return ingo#motion#helper#AdditionalMovement(a:isSpecialLastLineTreatment)
endfunction
else
function! s:AdditionalMovement( isSpecialLastLineTreatment )
    let l:save_ww = &whichwrap
    set whichwrap+=l
    if a:isSpecialLastLineTreatment && line('.') == line('$') && &virtualedit !=# 'onemore' && &virtualedit !=# 'all'
	" For the last line in the buffer, that still doesn't work in
	" operator-pending mode, unless we can do virtual editing.
	let l:save_ve = &virtualedit
	set virtualedit=onemore
	normal! l
	augroup IngoLibraryTempVirtualEdit
	    execute 'autocmd! CursorMoved * set virtualedit=' . l:save_ve . ' | autocmd! IngoLibraryTempVirtualEdit'
	augroup END
    else
	normal! l
    endif
    let &whichwrap = l:save_ww
endfunction
endif
function! CountJump#CountJumpWithWrapMessage( mode, searchName, ... )
"*******************************************************************************
"* PURPOSE:
"   Implement a custom motion by jumping to the <count>th occurrence of the
"   passed pattern.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Normal mode: Jumps to the <count>th occurrence.
"   Visual mode: Extends the selection to the <count>th occurrence.
"   If the pattern doesn't match (a:count times), a beep is emitted.
"
"* INPUTS:
"   a:mode  Mode in which the search is invoked. Either 'n', 'v' or 'o'.
"	    Uppercase letters indicate special additional treatment for end
"	    patterns to end.
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". When empty, no wrap message is issued.
"   ...	    Arguments to search().
"
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:count = v:count1

    if a:mode ==? 'v'
	normal! gv
    endif

    let l:matchPosition = CountJump#CountSearchWithWrapMessage(l:count, a:searchName, a:000)
    if l:matchPosition != [0, 0]
	" Add the original cursor position to the jump list.
	call winrestview(l:save_view)
	normal! m'
	call setpos('.', [0] + l:matchPosition + [0])

	if a:mode ==# 'V' && &selection ==# 'exclusive' || a:mode ==# 'O'
	    " Special additional treatment for end patterns to end.
	    call s:AdditionalMovement(a:mode ==# 'O')
	endif
    endif
endfunction
function! CountJump#CountJump( mode, ... )
    " See CountJump#CountJumpWithWrapMessage().
    return call('CountJump#CountJumpWithWrapMessage', [a:mode, ''] + a:000)
endfunction
function! CountJump#JumpFunc( mode, JumpFunc, ... )
"*******************************************************************************
"* PURPOSE:
"   Implement a custom motion by invoking a jump function that is passed the
"   <count> and the optional arguments.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Normal mode: Jumps to the <count>th occurrence.
"   Visual mode: Extends the selection to the <count>th occurrence.
"   If the jump doesn't work, a beep is emitted.
"
"* INPUTS:
"   a:mode  Mode in which the search is invoked. Either 'n', 'v' or 'o'.
"	    Uppercase letters indicate special additional treatment for end jump
"	    to end.
"   a:JumpFunc		Function which is invoked to jump.
"   The jump function must take at least one argument:
"	a:count	Number of matches to jump to.
"   It can take more arguments which must then be passed in here:
"   ...	    Arguments to the passed a:JumpFunc
"   The jump function should position the cursor to the appropriate position in
"   the current window, and open any folds there. It is expected to beep and
"   keep the cursor at its original position when no appropriate position can be
"   found.
"
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:originalPosition = getpos('.')
    let l:count = v:count1

    if a:mode ==? 'v'
	normal! gv
    endif

    call call(a:JumpFunc, [l:count] + a:000)
    let l:matchPosition = getpos('.')
    if l:matchPosition != l:originalPosition
	" Add the original cursor position to the jump list.
	call winrestview(l:save_view)
	normal! m'
	call setpos('.', l:matchPosition)

	if a:mode ==# 'V' && &selection ==# 'exclusive' || a:mode ==# 'O'
	    " Special additional treatment for end jumps to end.
	    " The difference between normal mode, operator-pending and visual
	    " mode with 'selection' set to "exclusive" is that in the latter
	    " two, the motion must go _past_ the final "word" character, so that
	    " all characters of the "word" are selected. This is done by
	    " appending a 'l' motion after the search for the next "word".
	    "
	    " The 'l' motion only works properly at the end of the line (i.e.
	    " when the moved-over "word" is at the end of the line) when the 'l'
	    " motion is allowed to move over to the next line. Thus, the 'l'
	    " motion is added temporarily to the global 'whichwrap' setting.
	    " Without this, the motion would leave out the last character in the
	    " line.
	    let l:save_ww = &whichwrap
	    set whichwrap+=l
	    if a:mode ==# 'O' && line('.') == line('$') && &virtualedit !=# 'onemore' && &virtualedit !=# 'all'
		" For the last line in the buffer, that still doesn't work,
		" unless we can do virtual editing.
		let l:save_ve = &virtualedit
		set virtualedit=onemore
		normal! l
		augroup TempVirtualEdit
		    execute 'autocmd! CursorMoved * set virtualedit=' . l:save_ve . ' | autocmd! TempVirtualEdit'
		augroup END
	    else
		normal! l
	    endif
	    let &whichwrap = l:save_ww
	endif
    endif
endfunction
function! CountJump#CountJumpFuncWithWrapMessage( count, searchName, isBackward, SingleJumpFunc, ... )
"*******************************************************************************
"* PURPOSE:
"   Invoke a:JumpFunc and its arguments a:count'th times.
"   This function can be passed to CountJump#JumpFunc() to implement a custom
"   motion with a simple jump function that only performs single jumps.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Jumps a:count times and opens any closed folds there.
"   If it cannot jump (<count> times), a beep is emitted.
"
"* INPUTS:
"   a:count Number of occurrence to jump to.
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". When empty, no wrap message is issued.
"   a:SingleJumpFunc    Function which is invoked to perform a single jump.
"   It can take more arguments which must then be passed in here:
"   ...	    Arguments to the passed a:JumpFunc
"   The jump function should position the cursor to the appropriate position in
"   the current window and return the position. It is expected to keep the
"   cursor at its original position and return [0, 0] when no appropriate
"   position can be found.
"
"* RETURN VALUES:
"   List with the line and column position, or [0, 0], like searchpos().
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:isWrapped = 0
    let [l:prevLine, l:prevCol] = [line('.'), col('.')]
"****D echomsg '****' a:currentSyntaxId.':' string(synIDattr(a:currentSyntaxId, 'name')) 'colored in' synIDattr(a:currentHlgroupId, 'name')
    for l:i in range(1, a:count)
	let l:matchPosition = call(a:SingleJumpFunc, a:000)
	if l:matchPosition == [0, 0]
	    if l:i > 1
		" (Due to the count,) we've already moved to an intermediate
		" match. Undo that to behave like the old vi-compatible
		" motions. (Only the ]s motion has different semantics; it obeys
		" the 'wrapscan' setting and stays at the last possible match if
		" the setting is off.)
		call winrestview(l:save_view)
	    endif

	    " Ring the bell to indicate that no further match exists.
	    execute "normal! \<C-\>\<C-n>\<Esc>"

	    return l:matchPosition
	endif

	if ! a:isBackward && (l:prevLine > l:matchPosition[0] || l:prevLine == l:matchPosition[0] && l:prevCol >= l:matchPosition[1])
	    let l:isWrapped = 1
	elseif a:isBackward && (l:prevLine < l:matchPosition[0] || l:prevLine == l:matchPosition[0] && l:prevCol <= l:matchPosition[1])
	    let l:isWrapped = 1
	endif
	let [l:prevLine, l:prevCol] = l:matchPosition
    endfor

    " Open the fold at the final search result. This makes the search work like
    " the built-in motions, and avoids that some visual selections get stuck at
    " a match inside a closed fold.
    normal! zv

    if ! empty(a:searchName)
	if l:isWrapped
	    redraw
	    call s:WrapMessage(a:searchName, a:isBackward)
	else
	    " We need to clear any previous wrap message; it's confusing
	    " otherwise. /pattern searches do not have that problem, as they
	    " echo the search pattern.
	    echo
	endif
    endif

    return l:matchPosition
endfunction
function! CountJump#CountJumpFunc( count, SingleJumpFunc, ... )
    " See CountJump#CountJumpFuncWithWrapMessage().
    return call('CountJump#CountJumpFuncWithWrapMessage', [a:count, '', 0, a:SingleJumpFunc] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
