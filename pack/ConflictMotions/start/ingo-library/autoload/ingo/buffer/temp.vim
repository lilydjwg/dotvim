" ingo/buffer/temp.vim: Functions to execute stuff in a temp buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.006	16-Nov-2016	FIX: Correct delegation in
"				ingo#buffer#temp#Execute(); wrong recursive call
"				was used (after 1.027).
"				ENH: Add optional a:isSilent argument to
"				ingo#buffer#temp#Execute().
"   1.027.005	20-Aug-2016	Add ingo#buffer#temp#ExecuteWithText() and
"				ingo#buffer#temp#CallWithText() variants that
"				pre-initialize the buffer (a common use case).
"   1.025.004	29-Jul-2016	FIX: Temporarily reset 'switchbuf' in
"				ingo#buffer#temp#Execute(), to avoid that
"				"usetab" switched to another tab page.
"   1.023.003	07-Nov-2014	ENH: Add optional a:isReturnAsList flag to
"				ingo#buffer#temp#Execute() and
"				ingo#buffer#temp#Call().
"   1.013.002	05-Sep-2013	Name the temp buffer for
"				ingo#buffer#temp#Execute() and re-use previous
"				instances to avoid increasing the buffer numbers
"				and output of :ls!.
"   1.008.001	11-Jun-2013	file creation from ingobuffer.vim

function! s:SetBuffer( text )
    if empty(a:text) | return | endif
    call append(1, (type(a:text) == type([]) ? a:text : split(a:text, '\n', 1)))
    silent 1delete _
endfunction
let s:tempBufNr = 0
function! ingo#buffer#temp#Execute( ... )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command in an empty temporary scratch buffer and return the
"   contents of the buffer after the execution.
"* ASSUMPTIONS / PRECONDITIONS:
"   - a:command should have no side effects to the buffer (other than changing
"     its contents), as it will be reused on subsequent invocations. If you
"     change any buffer-local option, also undo the change!
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:command	Ex command to be invoked.
"   a:isIgnoreOutput	Flag whether to skip capture of the scratch buffer
"			contents and just execute a:command for its side
"			effects.
"   a:isReturnAsList	Flag whether to return the contents as a List of lines.
"   a:isSilent          Flag whether a:command is executed silently (default:
"			true).
"* RETURN VALUES:
"   Contents of the buffer, by default as one newline-delimited string, with
"   a:isReturnAsList as a List, like getline() does.
"******************************************************************************
    return call('ingo#buffer#temp#ExecuteWithText', [''] + a:000)
endfunction
function! ingo#buffer#temp#ExecuteWithText( text, command, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command in a temporary scratch buffer filled with a:text and
"   return the contents of the buffer after the execution.
"* ASSUMPTIONS / PRECONDITIONS:
"   - a:command should have no side effects to the buffer (other than changing
"     its contents) that "survive" a buffer deletion, as the buffer will be
"     reused on subsequent invocations. Setting 'filetype', buffer-local
"     mappings and custom commands seem to be fine, but beware of buffer-local
"     autocmds!
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text      List of lines, or String with newline-delimited lines.
"   a:command	Ex command to be invoked.
"   a:isIgnoreOutput	Flag whether to skip capture of the scratch buffer
"			contents and just execute a:command for its side
"			effects.
"   a:isReturnAsList	Flag whether to return the contents as a List of lines.
"   a:isSilent          Flag whether a:command is executed silently (default:
"			true).
"* RETURN VALUES:
"   Contents of the buffer, by default as one newline-delimited string, with
"   a:isReturnAsList as a List, like getline() does.
"******************************************************************************
    let l:isSilent = (a:0 >= 3 ? a:3 : 1)
    " It's hard to create a temp buffer in a safe way without side effects.
    " Switching the buffer can change the window view, may have a noticable
    " delay even with autocmds suppressed (maybe due to 'autochdir', or just a
    " sync in syntax highlighting), or even destroy the buffer ('bufhidden').
    " Splitting changes the window layout; there may not be room for another
    " window or tab. And autocmds may do all sorts of uncontrolled changes.
    let l:originalWindowLayout = winrestcmd()
	if s:tempBufNr && bufexists(s:tempBufNr)
	    let l:save_switchbuf = &switchbuf | set switchbuf= | " :sbuffer should always open a new split / must not apply "usetab" (so we can :close it without checking).
	    try
		noautocmd silent keepalt leftabove execute s:tempBufNr . 'sbuffer'
	    finally
		let &switchbuf = l:save_switchbuf
	    endtry
	    " The :bdelete got rid of the buffer contents and any buffer-local
	    " options; no need to clean the revived buffer.
	else
	    noautocmd silent keepalt leftabove 1new IngoLibraryTempBuffer
	    let s:tempBufNr = bufnr('')
	endif
    try
	call s:SetBuffer(a:text)
	execute (l:isSilent ? 'silent' : '') a:command
	if ! a:0 || ! a:1
	    let l:lines = getline(1, line('$'))
	    return (a:0 >= 2 && a:2 ? l:lines : join(l:lines, "\n"))
	endif
    finally
	noautocmd silent execute s:tempBufNr . 'bdelete!'
	silent! execute l:originalWindowLayout
    endtry
endfunction
function! ingo#buffer#temp#Call( Funcref, arguments, ... )
    return call('ingo#buffer#temp#ExecuteWithText', ['', 'call call(' . string(a:Funcref) . ',' . string(a:arguments) . ')'] + a:000)
endfunction
function! ingo#buffer#temp#CallWithText( text, Funcref, arguments, ... )
    return call('ingo#buffer#temp#ExecuteWithText', [a:text, 'call call(' . string(a:Funcref) . ',' . string(a:arguments) . ')'] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
