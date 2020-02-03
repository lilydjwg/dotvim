" ingo/actions/iterations.vim: Repeated action execution over several targets.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"   - ingo/escape/file.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.001	29-Jul-2016	file creation

function! ingo#actions#iterations#WinDo( alreadyVisitedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each window in the current tab page, unless the buffer is
"   in a:alreadyVisitedBuffers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:alreadyVisitedBuffers     Dictionary with already visited buffer numbers
"				as keys. Will be added to, and the same buffers
"				in other windows will be skipped. Pass 0 to
"				visit _all_ windows, regardless of the buffers
"				they display.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each window.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:originalWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    " By entering a window, its height is potentially increased from 0 to 1 (the
    " minimum for the current window). To avoid any modification, save the window
    " sizes and restore them after visiting all windows.
    let l:originalWindowLayout = winrestcmd()
    let l:didSwitchWindows = 0

    try
	for l:winNr in range(1, winnr('$'))
	    let l:bufNr = winbufnr(l:winNr)
	    if a:alreadyVisitedBuffers is# 0 || ! has_key(a:alreadyVisitedBuffers, l:bufNr)
		if l:winNr != winnr()
		    execute 'noautocmd' l:winNr . 'wincmd w'
		    let l:didSwitchWindows = 1
		endif
		if type(a:alreadyVisitedBuffers) == type({}) | let a:alreadyVisitedBuffers[bufnr('')] = 1 | endif

		call call(function('ingo#actions#ExecuteOrFunc'), a:000)
	    endif
	endfor
    finally
	if l:didSwitchWindows
	    noautocmd execute l:previousWinNr . 'wincmd w'
	    noautocmd execute l:originalWinNr . 'wincmd w'
	    silent! execute l:originalWindowLayout
	endif
    endtry
endfunction

function! ingo#actions#iterations#TabWinDo( alreadyVisitedTabPages, alreadyVisitedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each window in each tab page, unless the buffer is in
"   a:alreadyVisitedBuffers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:alreadyVisitedTabPages    Dictionary with already visited tabpage numbers
"				as keys. Will be added to, those tab pages will
"				be skipped. Pass empty Dictionary to visit _all_
"				tab pages.
"   a:alreadyVisitedBuffers     Dictionary with already visited buffer numbers
"				as keys. Will be added to, and the same buffers
"				in other windows / tab pages will be skipped.
"				Pass 0 to visit _all_ windows and tab pages,
"				regardless of the buffers they display.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each window.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:originalTabNr = tabpagenr()
    let l:didSwitchTabs = 0
    try
	for l:tabNr in range(1, tabpagenr('$'))
	    if ! has_key(a:alreadyVisitedTabPages, l:tabNr)
		let a:alreadyVisitedTabPages[l:tabNr] = 1
		if ! empty(a:alreadyVisitedBuffers) && ingo#collections#differences#ContainsLoosely(keys(a:alreadyVisitedBuffers), tabpagebuflist(l:tabNr))
		    " All buffers of that tab page have already been visited; no
		    " need to go there.
		    continue
		endif

		if l:tabNr != tabpagenr()
		    execute 'noautocmd' l:tabNr . 'tabnext'
		    let l:didSwitchTabs = 1
		endif

		let l:originalWinNr = winnr()
		let l:previousWinNr = winnr('#') ? winnr('#') : 1
		" By entering a window, its height is potentially increased from 0 to 1 (the
		" minimum for the current window). To avoid any modification, save the window
		" sizes and restore them after visiting all windows.
		let l:originalWindowLayout = winrestcmd()
		let l:didSwitchWindows = 0

		try
		    for l:winNr in range(1, winnr('$'))
			let l:bufNr = winbufnr(l:winNr)
			if a:alreadyVisitedBuffers is# 0 || ! has_key(a:alreadyVisitedBuffers, l:bufNr)
			    execute 'noautocmd' l:winNr . 'wincmd w'

			    let l:didSwitchWindows = 1
			    if type(a:alreadyVisitedBuffers) == type({}) | let a:alreadyVisitedBuffers[bufnr('')] = 1 | endif

			    call call(function('ingo#actions#ExecuteOrFunc'), a:000)
			endif
		    endfor
		finally
		    if l:didSwitchWindows
			noautocmd execute l:previousWinNr . 'wincmd w'
			noautocmd execute l:originalWinNr . 'wincmd w'
			silent! execute l:originalWindowLayout
		    endif
		endtry
	    endif
	endfor
    finally
	if l:didSwitchTabs
	    noautocmd execute l:originalTabNr . 'tabnext'
	endif
    endtry
endfunction

function! s:GetNextArgNr( argNr, alreadyVisitedBuffers )
    let l:argNr = a:argNr + 1   " Try next argument.
    while l:argNr <= argc()
	let l:bufNr = bufnr(ingo#escape#file#bufnameescape(argv(a:argNr - 1)))
	if l:bufNr == -1 || type(a:alreadyVisitedBuffers) != type({}) || ! has_key(a:alreadyVisitedBuffers, l:bufNr)
	    return l:argNr
	endif

	" That one was already visited; continue searching.
	let l:argNr += 1
    endwhile
    return -1
endfunction
function! ingo#actions#iterations#ArgDo( alreadyVisitedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each argument in the argument list, unless the buffer is
"   in a:alreadyVisitedBuffers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Prints any Vim exception as error message.
"* INPUTS:
"   a:alreadyVisitedBuffers     Dictionary with already visited buffer numbers
"				as keys. Will be added to, and the same buffers
"				in other arguments will be skipped. Pass 0 to
"				visit _all_ arguments.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each window.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   Number of Vim exceptions raised while iterating through the argument list
"   (e.g. errors when loading buffers) or from executing a:Action.
"******************************************************************************
    let l:originalBufNr = bufnr('')
    let l:originalWindowLayout = winrestcmd()
    let l:originalWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    let l:nextArgNr = s:GetNextArgNr(0, a:alreadyVisitedBuffers)
    if l:nextArgNr == -1
	return | " No arguments left.
    endif

    let l:didSplit = 0
    let l:failureCnt = 0
    try
	try
	    execute 'noautocmd silent keepalt leftabove' l:nextArgNr . 'sargument'
	    let l:didSplit = 1
	catch
	    call ingo#msg#VimExceptionMsg()
	    let l:failureCnt += 1
	    if bufnr('') == l:originalBufNr
		" We failed to split to the target buffer; bail out, as we need
		" the split.
		return l:failureCnt
	    endif
	endtry

	while 1
	    let l:bufNr = bufnr('')
	    if type(a:alreadyVisitedBuffers) == type({}) | let a:alreadyVisitedBuffers[bufnr('')] = 1 | endif

	    try
		call call(function('ingo#actions#ExecuteOrFunc'), a:000)
	    catch
		call ingo#msg#VimExceptionMsg()
		let l:failureCnt += 1
	    endtry

	    let l:nextArgNr = s:GetNextArgNr(l:nextArgNr, a:alreadyVisitedBuffers)
	    if l:nextArgNr == -1
		break
	    endif

	    try
		execute 'noautocmd silent keepalt' l:nextArgNr . 'argument'
	    catch
		call ingo#msg#VimExceptionMsg()
		let l:failureCnt += 1
	    endtry
	endwhile
    finally
	if l:didSplit
	    noautocmd silent! close!
	    noautocmd execute l:previousWinNr . 'wincmd w'
	    noautocmd execute l:originalWinNr . 'wincmd w'
	    silent! execute l:originalWindowLayout
	endif
    endtry

    return l:failureCnt
endfunction

function! s:GetNextBufNr( bufNr, alreadyVisitedBuffers )
    let l:bufNr = a:bufNr + 1   " Try next buffer.
    let l:lastBufNr = bufnr('$')
    while l:bufNr <= l:lastBufNr
	if buflisted(l:bufNr) && (type(a:alreadyVisitedBuffers) != type({}) || ! has_key(a:alreadyVisitedBuffers, l:bufNr))
	    return l:bufNr
	endif

	" That one was already visited; continue searching.
	let l:bufNr += 1
    endwhile
    return -1
endfunction
function! ingo#actions#iterations#BufDo( alreadyVisitedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each listed buffer, unless the buffer is in
"   a:alreadyVisitedBuffers.
"* SEE ALSO:
"   To execute an Action in a single visible buffer, use
"   ingo#buffer#visible#Execute() / ingo#buffer#visible#Call().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Prints any Vim exception as error message.
"* INPUTS:
"   a:alreadyVisitedBuffers     Dictionary with already visited buffer numbers
"				as keys. Will be added to. Pass 0 or {} to visit
"				_all_ buffers.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each buffer.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   Number of Vim exceptions raised while iterating through the buffer list
"   (e.g. errors when loading buffers) or from executing a:Action.
"******************************************************************************
    let l:originalWindowLayout = winrestcmd()
    let l:originalWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    let l:nextBufNr = s:GetNextBufNr(0, a:alreadyVisitedBuffers)
    if l:nextBufNr == -1
	return | " No buffers left.
    endif

    let l:didSplit = 0
    let l:failureCnt = 0
    let l:save_switchbuf = &switchbuf | set switchbuf= | " :sbuffer should always open a new split (so we can :close it without checking).
    try
	try
	    execute 'noautocmd silent keepalt leftabove' l:nextBufNr . 'sbuffer'
	catch
	    call ingo#msg#VimExceptionMsg()
	    let l:failureCnt += 1
	    if bufnr('') != l:nextBufNr
		" We failed to split to the target buffer; bail out, as we need
		" the split.
		return l:failureCnt
	    endif
	finally
	    let &switchbuf = l:save_switchbuf
	endtry

	let l:didSplit = 1
	while 1
	    let l:bufNr = bufnr('')
	    if type(a:alreadyVisitedBuffers) == type({}) | let a:alreadyVisitedBuffers[bufnr('')] = 1 | endif

	    try
		call call(function('ingo#actions#ExecuteOrFunc'), a:000)
	    catch
		call ingo#msg#VimExceptionMsg()
		let l:failureCnt += 1
	    endtry

	    let l:nextBufNr = s:GetNextBufNr(l:nextBufNr, a:alreadyVisitedBuffers)
	    if l:nextBufNr == -1
		break
	    endif

	    try
		execute 'noautocmd silent keepalt' l:nextBufNr . 'buffer'
	    catch
		call ingo#msg#VimExceptionMsg()
		let l:failureCnt += 1
	    endtry
	endwhile
    finally
	if l:didSplit
	    noautocmd silent! close!
	    noautocmd execute l:previousWinNr . 'wincmd w'
	    noautocmd execute l:originalWinNr . 'wincmd w'
	    silent! execute l:originalWindowLayout
	endif
    endtry

    return l:failureCnt
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
