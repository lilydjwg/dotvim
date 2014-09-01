" ingo/selection.vim: Functions for accessing the visually selected text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.002	05-Sep-2013	Also avoid clobbering the last change ('.') in
"				ingo#selection#Get() when 'cpo' contains "y".
"   1.006.001	24-May-2013	file creation from ingointegration.vim.

function! ingo#selection#Get()
"******************************************************************************
"* PURPOSE:
"   Retrieve the contents of the current visual selection without clobbering any
"   register and the last change.
"* ASSUMPTIONS / PRECONDITIONS:
"   Visual selection is / has been made.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Text of visual selection.
"* SEE ALSO:
"   To execute an action while keeping the default register contents, use
"   ingo#register#KeepRegisterExecuteOrFunc().
"   To retrieve the contents of lines in a range, use ingo#range#Get().
"******************************************************************************
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    if stridx(&cpoptions, 'y') != -1
	let l:save_cpoptions = &cpoptions
	set cpoptions-=y
    endif
	let l:save_reg = getreg('"')
	let l:save_regmode = getregtype('"')
	    execute 'silent! normal! gvy'
	    let l:selection = @"
	call setreg('"', l:save_reg, l:save_regmode)
    if exists('l:save_cpoptions')
	let &cpoptions = l:save_cpoptions
    endif
    let &clipboard = l:save_clipboard

    return l:selection
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
