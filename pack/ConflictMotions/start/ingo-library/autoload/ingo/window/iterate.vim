" ingo/window/iterate.vim: Functions to iterate over windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

if exists('*win_execute')
    function! ingo#window#iterate#WinRange( winRange, Action, ... ) abort
    "******************************************************************************
    "* PURPOSE:
    "   Execute a:Action in the a:winRange windows in the current tab page.
    "* ASSUMPTIONS / PRECONDITIONS:
    "   - a:Action must not remove or add windows, as that will mess with
    "     iteration.
    "* EFFECTS / POSTCONDITIONS:
    "   - Window sizes may be restored after iteration (in the legacy
    "     non-win_execute() version). Any window resizing would then be lost.
    "* INPUTS:
    "   a:winRange  List of window numbers that should be visited (in no
    "               guaranteed order).
    "   a:Action    Either a Funcref or an expression to be :execute'd.
    "   a:arguments Value(s) to be passed to the a:Action Funcref or used for
    "               occurrences of "v:val" inside the a:Action expression. The
    "               v:val is inserted literally (as a Number, String, List,
    "               Dict)!
    "* RETURN VALUES:
    "   None.
    "******************************************************************************
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if ! l:isFuncref
	    let l:command = ingo#actions#RenderExCommandWithVal(a:Action, a:000)
	endif

	if len(a:winRange) == 1 && a:winRange[0] == winnr()
	    if l:isFuncref
		call call(a:Action, a:000)
	    else
		execute l:command
	    endif

	    return
	endif

	let l:command = ((l:isFuncref) ?
	\   'call call(a:Action, a:000)' :
	\   'execute ' . string(l:command)
	\)

	for l:winNr in a:winRange
	    call win_execute(win_getid(l:winNr), l:command)
	endfor
    endfunction
else
    function! ingo#window#iterate#WinRange( winRange, Action, ... ) abort
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if ! l:isFuncref
	    let l:command = ingo#actions#RenderExCommandWithVal(a:Action, a:000)
	endif

	if len(a:winRange) == 1 && a:winRange[0] == winnr()
	    if l:isFuncref
		call call(a:Action, a:000)
	    else
		execute l:command
	    endif

	    return
	endif

	" By entering a window, its height is potentially increased from 0 to 1 (the
	" minimum for the current window). To avoid any modification, save the window
	" sizes and restore them after visiting all windows.
	    let l:save_eventignore = &eventignore
		let l:originalWindowLayout = winrestcmd()
		    let l:originalWinNr = winnr()
		    let l:previousWinNr = winnr('#') ? winnr('#') : 1
	set eventignore+=BufEnter,BufLeave,WinEnter,WinLeave,CmdwinEnter,CmdwinLeave
	try
	    if a:winRange == range(1, winnr('$'))
		if l:isFuncref
		    keepjumps windo call call(a:Action, a:000)
		else
		    keepjumps windo execute l:command
		endif
	    else
		if l:isFuncref
		    keepjumps windo if index(a:winRange, winnr()) | call call(a:Action, a:000) | endif
		else
		    keepjumps windo if index(a:winRange, winnr()) | execute l:command | endif
		endif
	    endif
	finally
		    noautocmd execute l:previousWinNr . 'wincmd w'
		    noautocmd execute l:originalWinNr . 'wincmd w'
		silent! execute l:originalWindowLayout
	    let &eventignore = l:save_eventignore
	endtry
    endfunction
endif

function! ingo#window#iterate#All( Action, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Execute a:Action in all windows in the current tab page.
"* ASSUMPTIONS / PRECONDITIONS:
"   - a:Action must not remove or add windows, as that will mess with
"     iteration.
"* EFFECTS / POSTCONDITIONS:
"   - Window sizes may be restored after iteration (in the legacy
"     non-win_execute() version). Any window resizing would then be lost.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be :execute'd.
"   a:arguments Value(s) to be passed to the a:Action Funcref or used for
"               occurrences of "v:val" inside the a:Action expression. The
"               v:val is inserted literally (as a Number, String, List,
"               Dict)!
"* RETURN VALUES:
"   None.
"******************************************************************************
    call call('ingo#window#iterate#WinRange', [range(1, winnr('$')), a:Action] + a:000)
endfunction

function! ingo#window#iterate#ActionWithCatch( Action, ... ) abort
    let l:isFuncref = (type(a:Action) == type(function('tr')))

    if ! l:isFuncref
	let l:command = ingo#actions#RenderExCommandWithVal(a:Action, a:000)
    endif

    try
	if l:isFuncref
	    call call(a:Action, a:000)
	else
	    execute l:command
	endif
    catch /^Vim\%((\a\+)\)\=:/
	let s:isSuccess = 0

	if ingo#err#IsSet()
	    call ingo#msg#ErrorMsg(ingo#err#Get())
	endif
	call ingo#err#Set(printf('%s: %s', ingo#buffer#NameOrDefault(bufname('')), ingo#msg#MsgFromVimException()))
    endtry
endfunction

function! ingo#window#iterate#AllWithErrorsEchoed( Action, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Execute a:Action in all windows in the current tab page. Errors / exceptions
"   do not abort the iteration, but are reported (with the affected buffer name
"   prepended).
"* ASSUMPTIONS / PRECONDITIONS:
"   - a:Action must not remove or add windows, as that will mess with iteration.
"* EFFECTS / POSTCONDITIONS:
"   - Window sizes may be restored after iteration (in the legacy
"     non-win_execute() version). Any window resizing would then be lost.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be :execute'd.
"   a:arguments Value(s) to be passed to the a:Action Funcref or used for
"               occurrences of "v:val" inside the a:Action expression. The
"               v:val is inserted literally (as a Number, String, List,
"               Dict)!
"* RETURN VALUES:
"   1 if complete success, 0 if error(s) / exception(s) occurred. The last error
"   message is then available from ingo#err#Get(); previous errors have already
"   been echoed.
"******************************************************************************
    call ingo#err#Clear()
    let s:isSuccess = 1
	call call('ingo#window#iterate#All', [function('ingo#window#iterate#ActionWithCatch'), a:Action] + a:000)
    return s:isSuccess
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
