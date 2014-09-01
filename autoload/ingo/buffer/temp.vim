" ingo/buffer/temp.vim: Functions to execute stuff in a temp buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.002	05-Sep-2013	Name the temp buffer for
"				ingo#buffer#temp#Execute() and re-use previous
"				instances to avoid increasing the buffer numbers
"				and output of :ls!.
"   1.008.001	11-Jun-2013	file creation from ingobuffer.vim

let s:tempBufNr = 0
function! ingo#buffer#temp#Execute( command, ...)
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command in an empty temporary scratch buffer and return the
"   contents of the buffer after the execution.
"* ASSUMPTIONS / PRECONDITIONS:
"   - a:command should have no side effects to the buffer, as it will be reused
"     on subsequent invocations. If you change any buffer-local option, also
"     undo the change!
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:command	Ex command to be invoked.
"   a:isIgnoreOutput	Flag whether to skip capture of the scratch buffer
"			contents and just execute a:command for its side
"			effects.
"* RETURN VALUES:
"   Contents of the buffer.
"******************************************************************************
    " It's hard to create a temp buffer in a safe way without side effects.
    " Switching the buffer can change the window view, may have a noticable
    " delay even with autocmds suppressed (maybe due to 'autochdir', or just a
    " sync in syntax highlighting), or even destroy the buffer ('bufhidden').
    " Splitting changes the window layout; there may not be room for another
    " window or tab. And autocmds may do all sorts of uncontrolled changes.
    let l:originalWindowLayout = winrestcmd()
	if s:tempBufNr && bufexists(s:tempBufNr)
	    noautocmd silent keepalt leftabove execute s:tempBufNr . 'sbuffer'
	    " The :bdelete got rid of the buffer contents; no need to clean the
	    " revived buffer.
	else
	    noautocmd silent keepalt leftabove 1new IngoLibraryTempBuffer
	    let s:tempBufNr = bufnr('')
	endif
    try
	silent execute a:command
	if ! a:0 || ! a:1
	    return join(getline(1, line('$')), "\n")
	endif
    finally
	noautocmd silent execute s:tempBufNr . 'bdelete!'
	silent! execute l:originalWindowLayout
    endtry
endfunction
function! ingo#buffer#temp#Call( Funcref, arguments, ... )
    return call('ingo#buffer#temp#Execute', ['call call(' . string(a:Funcref) . ',' . string(a:arguments) . ')'] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
