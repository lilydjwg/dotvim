" ingo/buffers.vim: Functions to manipulate buffers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffers#Delete( buffersToDelete, isForce ) abort
"******************************************************************************
"* PURPOSE:
"   Delete (:bdelete) all buffers in a:buffersToDelete, and report any
"   encountered errors (with the affected buffer name prepended).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - Buffers in a:buffersToDelete are deleted from the buffer list.
"* INPUTS:
"   a:buffersToDelete   List of buffer numbers.
"   a:isForce           Force flag; uses :bdelete! if true.
"* RETURN VALUES:
"   1 if complete success, 0 if error(s) / exception(s) occurred. The last error
"   message is then available from ingo#err#Get(); previous errors have already
"   been echoed.
"******************************************************************************
    call ingo#err#Clear()
    let l:isSuccess = 1
    for l:bufNr in a:buffersToDelete
	try
	    execute l:bufNr . 'bdelete' . (a:isForce ? '!' : '')
	catch /^Vim\%((\a\+)\)\=:/
	    let l:isSuccess = 0

	    if ingo#err#IsSet()
		call ingo#msg#ErrorMsg(ingo#err#Get())
	    endif
	    call ingo#err#Set(printf('%s: %s', ingo#buffer#NameOrDefault(bufname(l:bufNr)), ingo#msg#MsgFromVimException()))
	endtry
    endfor

    return l:isSuccess
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
