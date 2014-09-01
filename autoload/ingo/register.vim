" ingo/register.vim: Functions for accessing Vim registers.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.015.003	18-Nov-2013	FIX: Actually return the result of a Funcref
"				passed to
"				ingo#register#KeepRegisterExecuteOrFunc().
"   1.014.002	27-Oct-2013	Add ingo#register#KeepRegisterExecuteOrFunc().
"   1.011.001	09-Jul-2013	file creation

function! ingo#register#Default()
    let l:values = split(&clipboard, ',')
    if index(l:values, 'unnamedplus') != -1
	return '+'
    elseif index(l:values, 'unnamed') != -1
	return '*'
    else
	return '"'
    endif
endfunction

function! ingo#register#KeepRegisterExecuteOrFunc( Action, ... )
"******************************************************************************
"* PURPOSE:
"   Commands in the executed a:Action do not modify the default register.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or Ex commands to be :executed.
"   a:arguments Value(s) to be passed to the a:Action Funcref (but not the
"		Ex commands).
"* RETURN VALUES:
"   Result of evaluating a:Action, for Ex commands you need to use :return.
"******************************************************************************
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    if stridx(&cpoptions, 'y') != -1
	let l:save_cpoptions = &cpoptions
	set cpoptions-=y
    endif
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    try
	return call('ingo#actions#ExecuteOrFunc', [a:Action] + a:000)
    finally
	call setreg('"', l:save_reg, l:save_regmode)
	if exists('l:save_cpoptions')
	    let &cpoptions = l:save_cpoptions
	endif
	let &clipboard = l:save_clipboard
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
