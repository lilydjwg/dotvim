" CountJump.vim: Move to a buffer position via repeated jumps (or searches). 
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
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

function! CountJump#CountSearch( count, searchArguments )
"*******************************************************************************
"* PURPOSE:
"   Search for the <count>th occurrence of the passed search() pattern and
"   arguments. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"
"* EFFECTS / POSTCONDITIONS:
"   Jumps to the <count>th occurrence and opens any closed folds there. 
"   If the pattern doesn't match (<count> times), a beep is emitted. 
"
"* INPUTS:
"   a:count Number of occurrence to jump to. 
"   a:searchArguments	Arguments to search() as a List [{pattern}, {flags}, ...]
"
"* RETURN VALUES: 
"   List with the line and column position, or [0, 0], like searchpos(). 
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:searchArguments = copy(a:searchArguments)

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
	    let l:searchArguments[1] = substitute(l:searchArguments[1], 'c', '', 'g')
	endif
    endfor

    " Open the fold at the final search result. This makes the search work like
    " the built-in motions, and avoids that some visual selections get stuck at
    " a match inside a closed fold. 
    normal! zv

    return l:matchPosition
endfunction
function! CountJump#CountJump( mode, ... )
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
"   If the pattern doesn't match (<count> times), a beep is emitted. 
"
"* INPUTS:
"   a:mode  Mode in which the search is invoked. Either 'n', 'v' or 'o'. 
"	    With 'O': Special additional treatment for operator-pending mode
"	    with a pattern to end. 
"   ...	    Arguments to search(). 
"
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    let l:save_view = winsaveview()

    if a:mode ==# 'v'
	normal! gv
    endif

    let l:matchPosition = CountJump#CountSearch(v:count1, a:000)
    if l:matchPosition != [0, 0]
	" Add the original cursor position to the jump list. 
	call winrestview(l:save_view)
	normal! m'
	call setpos('.', [0] + l:matchPosition + [0])

	if a:mode ==# 'O'
	    " Special additional treatment for operator-pending mode with a pattern
	    " to end. 
	    " The difference between normal mode, visual and operator-pending 
	    " mode is that in the latter, the motion must go _past_ the final
	    " character, so that all characters are selected. This is done by
	    " appending a 'l' motion after the search. 
	    "
	    " In operator-pending mode, the 'l' motion only works properly
	    " at the end of the line (i.e. when the moved-over "word" is at
	    " the end of the line) when the 'l' motion is allowed to move
	    " over to the next line. Thus, the 'l' motion is added
	    " temporarily to the global 'whichwrap' setting. 
	    " Without this, the motion would leave out the last character in
	    " the line. I've also experimented with temporarily setting
	    " "set virtualedit=onemore", but that didn't work. 
	    let l:save_ww = &whichwrap
	    set whichwrap+=l
	    normal! l
	    let &whichwrap = l:save_ww
	endif
    endif
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
"	    With 'O': Special additional treatment for operator-pending mode
"	    with a characterwise jump. 
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

    if a:mode ==# 'v'
	normal! gv
    endif

    call call(a:JumpFunc, [v:count1] + a:000)
    let l:matchPosition = getpos('.')
    if l:matchPosition != l:originalPosition
	" Add the original cursor position to the jump list. 
	call winrestview(l:save_view)
	normal! m'
	call setpos('.', l:matchPosition)

	if a:mode ==# 'O'
	    " Special additional treatment for operator-pending mode with a
	    " characterwise jump. 
	    " The difference between normal mode, visual and operator-pending 
	    " mode is that in the latter, the motion must go _past_ the final
	    " character, so that all characters are selected. This is done by
	    " appending a 'l' motion after the search. 
	    "
	    " In operator-pending mode, the 'l' motion only works properly
	    " at the end of the line (i.e. when the moved-over "word" is at
	    " the end of the line) when the 'l' motion is allowed to move
	    " over to the next line. Thus, the 'l' motion is added
	    " temporarily to the global 'whichwrap' setting. 
	    " Without this, the motion would leave out the last character in
	    " the line. I've also experimented with temporarily setting
	    " "set virtualedit=onemore", but that didn't work. 
	    let l:save_ww = &whichwrap
	    set whichwrap+=l
	    normal! l
	    let &whichwrap = l:save_ww
	endif
    endif
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
