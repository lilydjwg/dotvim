" ingo/ftplugin/onbufwinenter.vim: Execute a filetype-specific command after the buffer is fully loaded.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:autocmdCnt = 0
function! ingo#ftplugin#onbufwinenter#Execute( Action, ... )
"******************************************************************************
"* MOTIVATION:
"   You want to execute a command from a ftplugin (e.g. "normal! gg0") that only
"   is effective when the buffer is already fully loaded, modelines have been
"   processed, other autocmds have run, etc.
"
"* PURPOSE:
"   Schedule the passed a:command to execute once after the current buffer has
"   been fully loaded and is now displayed in a window (BufWinEnter).
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action	Ex command or Funcref to be executed.
"   a:when	Optional configuration of when a:Action is executed.
"		"": By default, it is only executed on the BufWinEnter event, i.e.
"		only when the buffer actually is being loaded.
"		"always": If you want to always execute it (and can live with it
"		being potentially executed twice), so that it is also executed
"		when the user changes the filetype of an existing buffer.
"		"delayed": BufWinEnter is still too early if you need to
"		consider effects of :edit +cmd; these are only executed after
"		the buffer is displayed and the autocmds have run. This adds
"		another wait after BufWinEnter to run a:Action only after the
"		user started editing for real.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if a:0 && a:1 ==# 'always'
	call ingo#actions#ExecuteOrFunc(a:Action)
    endif

    let s:autocmdCnt += 1
    let l:groupName = 'IngoLibraryOnBufWinEnter' . s:autocmdCnt
    execute 'augroup' l:groupName
	autocmd!
	if a:0 && a:1 ==# 'delayed'
	    execute 'autocmd BufWinEnter <buffer> autocmd' l:groupName 'BufWinLeave,CursorHold,CursorMoved,InsertEnter,WinLeave <buffer>' ingo#actions#GetExecuteOrFuncCommand(a:Action) '| autocmd!' l:groupName '* <buffer>'
	else
	    execute 'autocmd BufWinEnter <buffer>' ingo#actions#GetExecuteOrFuncCommand(a:Action) '| autocmd!' l:groupName '* <buffer>'
	endif
	" Remove the run-once autocmd in case the this command was NOT set up
	" during the loading of the buffer (but e.g. by a :setfiletype in an
	" existing buffer), so that it doesn't linger and surprise the user
	" later on.
	execute 'autocmd BufWinLeave,CursorHold,CursorHoldI,WinLeave <buffer> autocmd!' l:groupName '* <buffer>'
    augroup END
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
