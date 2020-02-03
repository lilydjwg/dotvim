" ingo/selection.vim: Functions for accessing the visually selected text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2019 Ingo Karkat
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
"   Moves the cursor to the beginning of the selected text.
"   Clobbers v:count.
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
	    execute 'silent! keepjumps normal! gvy'
	    let l:selection = @"
	call setreg('"', l:save_reg, l:save_regmode)
    if exists('l:save_cpoptions')
	let &cpoptions = l:save_cpoptions
    endif
    let &clipboard = l:save_clipboard

    return l:selection
endfunction

function! ingo#selection#Set( startPos, endPos, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Sets the visual selection to the passed area.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Affects what the next gv command will select.
"* INPUTS:
"   a:startPos  [lnum, col] or [0, lnum, col, 0] of the start ('<) of the new
"               selection.
"   a:endPos    [lnum, col] or [0, lnum, col, 0] of the end ('>) of the new
"               selection.
"   a:mode      One of v, V, or CTRL-V. Defaults to characterwise.
"* RETURN VALUES:
"   1 if successful, 0 if one position could not be set.
"******************************************************************************
    let l:mode = (a:0 ? a:1 : 'v')
    if visualmode() !=# l:mode && ! empty(l:mode)
	execute 'normal!' l:mode . "\<Esc>"
    endif
    let l:result = 0
    let l:result += ingo#compat#setpos("'<", ingo#pos#Make4(a:startPos))
    let l:result += ingo#compat#setpos("'>", ingo#pos#Make4(a:endPos))

    return (l:result == 0)
endfunction
function! ingo#selection#Make( ... ) abort
"******************************************************************************
"* PURPOSE:
"   Creates a new visual selection on the passed area.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes to visual mode.
"* INPUTS:
"   a:startPos  [lnum, col] of the start ('<) of the new selection.
"   a:endPos    [lnum, col] of the end ('>) of the new selection.
"   a:mode      One of v, V, or CTRL-V. Defaults to characterwise.
"* RETURN VALUES:
"   1 if successful, 0 if one position could not be set.
"******************************************************************************
    if call('ingo#selection#Set', a:000) == 0
	normal! gv
	return 1
    else
	return 0
    endif
endfunction

function! ingo#selection#GetInclusiveEndPos() abort
    if &selection ==# 'exclusive'
	let l:pos = getpos("'>")
	let l:charBeforePosition = matchstr(getline(l:pos[1]), '.\%' . l:pos[2] . 'c')
	let l:pos[2] -= len(l:charBeforePosition)
	return l:pos
    else
	return getpos("'>")
    endif
endfunction
function! ingo#selection#GetExclusiveEndPos() abort
    if &selection ==# 'exclusive'
	return getpos("'>")
    else
	let l:pos = getpos("'>")
	let l:charAtPosition = matchstr(getline(l:pos[1]), '\%' . l:pos[2] . 'c.')
	let l:pos[2] += len(l:charAtPosition)
	return l:pos
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
