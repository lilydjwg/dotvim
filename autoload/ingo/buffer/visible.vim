" ingo/buffer/visible.vim: Functions to execute stuff in a visible buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.008.001	11-Jun-2013	file creation from ingobuffer.vim

function! ingo#buffer#visible#Execute( bufnr, command )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command in a visible buffer.
"   Some commands (e.g. :update) operate in the context of the current buffer
"   and must therefore be visible in a window to be invoked. This function
"   ensures that the passed command is executed in the context of the passed
"   buffer number.

"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"   The current window and buffer loaded into it remain the same.
"* INPUTS:
"   a:bufnr Buffer number of an existing buffer where the function should be
"   executed in.
"   a:command	Ex command to be invoked.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:winnr = bufwinnr(a:bufnr)
    if l:winnr == -1
	" The buffer is hidden. Make it visible to execute the passed function.
	" Use a temporary split window as ingo#buffer#temp#Execute() does, for
	" all the reasons outlined there.
	let l:originalWindowLayout = winrestcmd()
	    execute 'noautocmd silent keepalt leftabove sbuffer' a:bufnr
	try
	    execute a:command
	finally
	    noautocmd silent close
	    silent! execute l:originalWindowLayout
	endtry
    else
	" The buffer is visible in at least one window on this tab page.
	let l:currentWinNr = winnr()
	execute l:winnr . 'wincmd w'
	try
	    execute a:command
	finally
	    execute l:currentWinNr . 'wincmd w'
	endtry
    endif
endfunction
function! ingo#buffer#visible#Call( bufnr, Funcref, arguments )
    return ingo#buffer#visible#Execute(a:bufnr, 'call call(' . string(a:Funcref) . ',' . string(a:arguments) . ')')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
