" ingo/window/switches.vim: Functions for switching between windows.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.002	03-May-2013	Add optional isReturnError flag on
"				ingo#window#switches#GotoPreviousWindow().
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim

function! ingo#window#switches#GotoPreviousWindow( ... )
"*******************************************************************************
"* PURPOSE:
"   Goto the previous window (CTRL-W_p). If there is no previous window, but
"   only one other window, go there.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current window, or:
"   Prints warning message (unless a:isReturnError).
"* INPUTS:
"   a:isReturnError When flag is set, returns the warning message instead of
"		    printing it.
"* RETURN VALUES:
"   If ! a:isReturnError: 1 on success, 0 if there is no previous window.
"   If   a:isReturnError: '' on success, message if there is no previous window.
"*******************************************************************************
    let l:isReturnError = (a:0 && a:1)
    let l:problem = ''
    let l:window = 'p'

    if winnr('$') == 1
	let l:problem = 'Only one window'
    elseif winnr('#') == 0 || winnr('#') == winnr()
	if winnr('$') == 2
	    " There is only one more window, we take that one.
	    let l:window = 'w'
	else
	    let l:problem = 'No previous window'
	endif
    endif
    if ! empty(l:problem)
	if l:isReturnError
	    return l:problem
	else
	    call ingo#msg#WarningMsg(l:problem)
	    return 0
	endif
    endif

    execute 'noautocmd wincmd' l:window
    return (l:isReturnError ? '' : 1)
endfunction

" Record the current buffer's window and try to later return exactly to the same
" window, even if in the meantime, windows have been added or removed. This is
" an enhanced version of bufwinnr(), which will always yield the _first_ window
" containing a buffer.
function! ingo#window#switches#WinSaveCurrentBuffer()
    let l:buffersUpToCurrent = tabpagebuflist()[0 : winnr() - 1]
    let l:occurrenceCnt= len(filter(l:buffersUpToCurrent, 'v:val == bufnr("")'))
    return {'bufnr': bufnr(''), 'occurrenceCnt': l:occurrenceCnt}
endfunction
function! ingo#window#switches#WinRestoreCurrentBuffer( dict )
    let l:targetWinNr = -1

    if a:dict.occurrenceCnt == 1
	" We want the first occurrence of the buffer, bufwinnr() can do this for
	" us.
	let l:targetWinNr = bufwinnr(a:dict.bufnr)
    else
	" Go through all windows and find the N'th window containing our buffer.
	let l:winNrs = []
	for l:winNr in range(1, winnr('$'))
	    if winbufnr(l:winNr) == a:dict.bufnr
		call add(l:winNrs, l:winNr)
	    endif
	endfor

	if len(l:winNrs) < a:dict.occurrenceCnt
	    " There are less windows showing that buffer now; choose the last.
	    let l:targetWinNr = l:winNrs[-1]
	else
	    let l:targetWinNr = l:winNrs[a:dict.occurrenceCnt - 1]
	endif
    endif

    if l:targetWinNr == -1
	throw printf('WinRestoreCurrentBuffer: target buffer %d not found', a:dict.bufnr)
    endif

    execute l:targetWinNr . 'wincmd w'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
