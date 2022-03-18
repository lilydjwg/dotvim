" ingo/buffer/ephemeral.vim: Functions to execute stuff in the buffer that won't persist after the call.
"
" DEPENDENCIES:
"   - ingo/lines.vim autoload script
"   - ingo/undo.vim autoload script
"
" Copyright: (C) 2018-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffer#ephemeral#Call( Funcref, arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Funcref with a:arguments on the current buffer without persisting the changes.
"   Any modifications to the text (but not side effects like changing buffer
"   settings!) will be undone afterwards, as if nothing happened. Therefore, you
"   probably want to :return something about the buffer from a:Funcref.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Funcref   Funcref to be executed. Will be passed a:arguments.
"   a:arguments Arguments to be passed.
"   a:undoCnt   Optional number of changes that a:command will do. If this is a
"		fixed number and you know it, passing this is slightly more
"		efficient.
"* RETURN VALUES:
"   Return value of a:Funcref
"******************************************************************************
    let l:save_view = winsaveview()
    let l:save_modified = &l:modified
    let l:save_lines = getline(1, line('$'))
    let [l:save_change_begin, l:save_change_end] = [getpos("'["), getpos("']")]

    if ! a:0
	let l:undoChangeNumber = ingo#undo#GetChangeNumber()
    endif

    try
	return call(a:Funcref, a:arguments)
    finally
	try
	    " Using :undo to roll back the actions doesn't pollute the undo
	    " history. Only explicitly restore the saved lines as a fallback.
	    if a:0
		for l:i in range(a:1)
		    silent undo
		endfor
	    else
		if l:undoChangeNumber < 0
		    throw 'CannotUndo'
		endif
		" XXX: Inside a function invocation, no separate change is created.
		if changenr() > l:undoChangeNumber
		    silent execute 'undo' l:undoChangeNumber
"****D else | echomsg '**** no new undo change number'
		endif
	    endif

	    if line('$') != len(l:save_lines) || l:save_lines !=# getline(1, line('$'))
		" Fallback in case the undo somehow failed.
		throw 'CannotUndo'
	    endif
	catch /^CannotUndo$\|^Vim\%((\a\+)\)\=:E/
"****D echomsg '**** falling back to replace'
	    silent %delete _
	    silent call ingo#lines#PutBefore(1, l:save_lines)
	    silent $delete _

	    let &l:modified = l:save_modified
	endtry

	call ingo#change#Set(l:save_change_begin, l:save_change_end)
	call winrestview(l:save_view)
    endtry
endfunction

function! s:Executor( command )
    execute a:command
endfunction
function! ingo#buffer#ephemeral#Execute( command, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command on the current buffer without persisting the changes.
"   Any modifications to the text (but not side effects like changing buffer
"   settings!) will be undone afterwards, as if nothing happened. Therefore, you
"   probably want to do something like :keepalt write TEMPFLE to store the
"   changes somewhere else.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lines     List of lines (or String of a single line) to be temporarily
"		processed by a:command.
"   a:command	Ex command to be invoked.
"   a:undoCnt   Optional number of changes that a:command will do. If this is a
"		fixed number and you know it, passing this is slightly more
"		efficient.
"* RETURN VALUES:
"   None.
"******************************************************************************
    call call('ingo#buffer#ephemeral#Call', [function('s:Executor'), [a:command]] + a:000)
endfunction

function! ingo#buffer#ephemeral#CallForceModifiable( ... )
"******************************************************************************
"* PURPOSE:
"   Like ingo#buffer#ephemeral#Call(), but additionally make the buffer
"   modifiable by clearing 'nomodifiable' and 'readonly' temporarily.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Funcref   Funcref to be executed. Will be passed a:arguments.
"   a:arguments Arguments to be passed.
"   a:undoCnt   Optional number of changes that a:command will do. If this is a
"		fixed number and you know it, passing this is slightly more
"		efficient.
"* RETURN VALUES:
"   Return value of a:Funcref
"******************************************************************************
    let l:save_modifiable = &l:modifiable
    let l:save_readonly = &l:readonly
    setlocal modifiable noreadonly

    try
	return call('ingo#buffer#ephemeral#Call', a:000)
    finally
	let &l:readonly = l:save_readonly
	let &l:modifiable = l:save_modifiable
    endtry
endfunction
function! ingo#buffer#ephemeral#ExecuteForceModifiable( command, ...)
    call call('ingo#buffer#ephemeral#CallForceModifiable', [function('s:Executor'), [a:command]] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
