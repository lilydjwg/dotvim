" ingo/buffer/locate.vim: Functions to locate a buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.002	19-Nov-2016	Also prefer current / previous window in other
"				tab pages.
"   1.028.001	18-Nov-2016	file creation

function! s:FindBufferOnTabPage( isConsiderNearest, tabPageNr, bufNr )
    let l:bufferNumbers = tabpagebuflist(a:tabPageNr)

    if a:isConsiderNearest
	let l:currentIdx = tabpagewinnr(a:tabPageNr) - 1
	if l:bufferNumbers[l:currentIdx] == a:bufNr
	    return l:currentIdx + 1
	endif
	let l:previousIdx = tabpagewinnr(a:tabPageNr, '#') - 1
	if l:previousIdx >= 0 && l:bufferNumbers[l:previousIdx] == a:bufNr
	    return l:previousIdx + 1
	endif
    endif

    for l:i in range(len(l:bufferNumbers))
	if l:bufferNumbers[l:i] == a:bufNr
	    return l:i + 1
	endif
    endfor
    return 0
endfunction

function! ingo#buffer#locate#BufTabPageWinNr( bufNr )
"******************************************************************************
"* PURPOSE:
"   Locate the first window that contains a:bufNr, in this tab page (like
"   bufwinnr()), or in other tab pages. Can be used to emulate the behavior of
"   :sbuffer with 'switchbuf' containing "useopen,usetab".
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:bufNr                 Buffer number of the target buffer.
"* RETURN VALUES:
"   [tabpagenr, winnr] if the buffer is on a different tab page
"   [0, winnr] if the buffer is on the current tab page
"   [0, 0] if a:bufNr is not found in other windows
"******************************************************************************
    let l:winNr = bufwinnr(a:bufNr)
    if l:winNr > 0
	return [0, l:winNr]
    endif

    for l:tabPageNr in filter(range(1, tabpagenr('$')), 'v:val != ' . tabpagenr())
	let l:winNr = s:FindBufferOnTabPage(0, l:tabPageNr, a:bufNr)
	if l:winNr != 0
	    return [l:tabPageNr, l:winNr]
	endif
    endfor

    return [0, 0]
endfunction

function! ingo#buffer#locate#OtherWindowWithSameBuffer()
"******************************************************************************
"* PURPOSE:
"   Locate the first window that contains the same buffer as the current window,
"   but is not identical to the current window.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   winnr or 0 if there's no windows split on this tab page that contains the
"   same buffer
"******************************************************************************
    let [l:currentWinNr, l:currentBufNr] = [winnr(), bufnr('')]

    for l:winNr in range(1, winnr('$'))
	if l:winNr != l:currentWinNr && winbufnr(l:winNr) == l:currentBufNr
	    return l:winNr
	endif
    endfor

    return 0
endfunction

function! ingo#buffer#locate#NearestWindow( isSearchOtherTabPages, bufNr )
"******************************************************************************
"* PURPOSE:
"   Locate the window closest to the current one that contains a:bufNr. Like
"   bufwinnr() with different precedences, and optionally looking into other tab
"   pages.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:bufNr                 Buffer number of the target buffer.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the buffer is on a
"	different tab page
"   [0, winnr] if the buffer is on the current tab page
"   [0, 0] if a:bufNr is not found in other windows
"******************************************************************************
    let l:lastWinNr = winnr('#')
    if l:lastWinNr != 0 && winbufnr(l:lastWinNr) == a:bufNr
	return [tabpagenr(), l:lastWinNr]
    endif

    let [l:currentWinNr, l:lastWinNr] = [winnr(), winnr('$')]
    let l:offset = 1
    while l:currentWinNr - l:offset > 0 || l:currentWinNr + l:offset <= l:lastWinNr
	if winbufnr(l:currentWinNr - l:offset) == a:bufNr
	    return [tabpagenr(), l:currentWinNr - l:offset]
	elseif winbufnr(l:currentWinNr + l:offset) == a:bufNr
	    return [tabpagenr(), l:currentWinNr + l:offset]
	endif
	let l:offset += 1
    endwhile

    if ! a:isSearchOtherTabPages
	return [0, 0]
    endif

    let [l:currentTabPageNr, l:lastTabPageNr] = [tabpagenr(), tabpagenr('$')]
    let l:offset = 1
    while l:currentTabPageNr - l:offset > 0 || l:currentTabPageNr + l:offset <= l:lastTabPageNr
	let l:winNr = s:FindBufferOnTabPage(1, l:currentTabPageNr - l:offset, a:bufNr)
	if l:winNr != 0
	    return [l:currentTabPageNr - l:offset, l:winNr]
	endif
	let l:winNr = s:FindBufferOnTabPage(1, l:currentTabPageNr + l:offset, a:bufNr)
	if l:winNr != 0
	    return [l:currentTabPageNr + l:offset, l:winNr]
	endif
	let l:offset += 1
    endwhile

    return [0, 0]
endfunction

function! ingo#buffer#locate#Window( strategy, isSearchOtherTabPages, bufNr )
"******************************************************************************
"* PURPOSE:
"   Locate a window that contains a:bufNr, with a:strategy to determine
"   precedences. Similar to bufwinnr() with configurable precedences, and
"   optionally looking into other tab pages.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strategy              One of "first" or "nearest".
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:bufNr                 Buffer number of the target buffer.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the buffer is on a
"	different tab page
"   [0, winnr] if the buffer is on the current tab page
"   [0, 0] if a:bufNr is not found in other windows
"******************************************************************************
    if a:strategy ==# 'first'
	if a:isSearchOtherTabPages
	    return ingo#buffer#locate#BufTabPageWinNr(a:bufNr)
	else
	    let l:winNr = bufwinnr(a:bufNr)
	    return (l:winNr > 0 ? [0, l:winNr] : [0, 0])
	endif
    elseif a:strategy ==# 'nearest'
	return ingo#buffer#locate#NearestWindow(a:isSearchOtherTabPages, a:bufNr)
    else
	throw 'ASSERT: Unknown strategy ' . string(a:strategy)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
