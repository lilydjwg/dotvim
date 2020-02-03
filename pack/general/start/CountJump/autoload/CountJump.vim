" CountJump.vim: Move to a buffer position via repeated jumps (or searches).
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2009-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:WrapMessage( searchName, isBackward )
    if &shortmess !~# 's'
	call ingo#msg#WarningMsg(a:searchName . ' ' . (a:isBackward ? 'hit TOP, continuing at BOTTOM' : 'hit BOTTOM, continuing at TOP'))
    endif
endfunction
function! CountJump#CountSearchWithWrapMessage( count, searchName, SearchArguments )
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
"   a:SearchArguments	Arguments to search() as a List [{pattern}, {flags}, ...]
"			Or Funcref to a function that takes no arguments and
"			returns the search arguments (as a List).
"                       First search argument (pattern) may also be a Funcref
"                       that takes no arguments and returns the pattern.
"
"* RETURN VALUES:
"   List with the line and column position, or [0, 0], like searchpos().
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:searchArguments = (type(a:SearchArguments) == 2 ? call(a:SearchArguments, []) : copy(a:SearchArguments))
    if type(l:searchArguments[0]) == 2 | let l:searchArguments[0] = call(l:searchArguments[0], []) | endif
    let l:isWrapped = 0
    let l:isBackward = (get(l:searchArguments, 1, '') =~# 'b')
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
	if ! l:isBackward && ingo#pos#IsOnOrAfter([l:prevLine, l:prevCol], l:matchPosition)
	    let l:isWrapped = 1
	elseif l:isBackward && ingo#pos#IsOnOrBefore([l:prevLine, l:prevCol], l:matchPosition)
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
function! CountJump#CountSearch( count, SearchArguments )
    return CountJump#CountSearchWithWrapMessage(a:count, '', a:SearchArguments)
endfunction
function! CountJump#CountCountJumpWithWrapMessage( count, mode, searchName, ... )
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
"   a:count Which match should be jumped to.
"   a:mode  Mode in which the search is invoked. Either 'n', 'v' or 'o'.
"	    Uppercase letters indicate special additional treatment for end
"	    patterns to end.
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". When empty, no wrap message is issued.
"   ...	    Arguments to search().
"           Or Funcref to a function that takes no arguments and returns the
"           search arguments (as a List).
"           First search argument (pattern) may also be a Funcref that takes no
"           arguments and returns the pattern.
"
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:save_view = winsaveview()
    let l:count = a:count

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
	    call ingo#motion#helper#AdditionalMovement(a:mode ==# 'O')
	endif
    endif
endfunction
function! CountJump#CountJumpWithWrapMessage( mode, searchName, ... )
    return call('CountJump#CountCountJumpWithWrapMessage', [v:count1, a:mode, a:searchName] + a:000)
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
	    if a:mode ==# 'O' && line('.') == line('$') && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
		" For the last line in the buffer, that still doesn't work,
		" unless we can do virtual editing.
		let l:save_virtualedit = &virtualedit
		set virtualedit=onemore
		normal! l
		augroup TempVirtualEdit
		    execute 'autocmd! CursorMoved * set virtualedit=' . l:save_virtualedit . ' | autocmd! TempVirtualEdit'
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

	if ! a:isBackward && ingo#pos#IsOnOrAfter([l:prevLine, l:prevCol], l:matchPosition)
	    let l:isWrapped = 1
	elseif a:isBackward && ingo#pos#IsOnOrBefore([l:prevLine, l:prevCol], l:matchPosition)
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
function! CountJump#Mapping( Function, arguments ) abort
    try
	call call(a:Function, a:arguments)
	return 1
    catch /^CountJump:/
	call ingo#err#SetCustomException('CountJump')
	return 0
    catch '^\%(Vim:\)\?Interrupt$'
	return 1
    catch
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! CountJump#OMapping( Function, arguments  ) abort
    return ingo#register#pending#ExecuteOrFunc(function('CountJump#Mapping'), a:Function, a:arguments)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
