" ingo/ftplugin/onbufwinenter.vim: Execute a filetype-specific command after the buffer is fully loaded.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.001	23-Jul-2013	file creation from ingointegration.vim.

let s:autocmdCnt = 0
function! ingo#ftplugin#onbufwinenter#Execute( command, ... )
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
"   a:command	Ex command to be executed.
"   a:when	Optional configuration of when a:command is executed.
"		By default, it is only executed on the BufWinEnter event, i.e.
"		only when the buffer actually is being loaded. If you want to
"		always execute it (and can live with it being potentially
"		executed twice), so that it is also executed when the user
"		changes the filetype of an existing buffer, pass "always" in
"		here.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if a:0 && a:1 ==# 'always'
	execute a:command
    endif

    let s:autocmdCnt += 1
    let l:groupName = 'IngoLibraryOnBufWinEnter' . s:autocmdCnt
    execute 'augroup' l:groupName
	autocmd!
	execute 'autocmd BufWinEnter <buffer> execute' string(a:command) '| autocmd!' l:groupName '* <buffer>'
	" Remove the run-once autocmd in case the this command was NOT set up
	" during the loading of the buffer (but e.g. by a :setfiletype in an
	" existing buffer), so that it doesn't linger and surprise the user
	" later on.
	execute 'autocmd BufWinLeave,CursorHold,CursorHoldI,WinLeave <buffer> autocmd!' l:groupName '* <buffer>'
    augroup END
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
