" ingo/register.vim: Functions for accessing Vim registers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#register#All()
    return '[-a-zA-Z0-9":.%#=*+~/]'
endfunction
function! ingo#register#Writable()
    return '[-a-zA-Z0-9"*+_/]'
endfunction
function! ingo#register#IsWritable( register ) abort
    return (a:register =~# ingo#regexp#Anchored(ingo#register#Writable()))
endfunction

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

function! ingo#register#GetAsList( register )
"******************************************************************************
"* PURPOSE:
"   Get the contents of a:register as a List of lines. For a linewise register,
"   there is no trailing empty element (so the returned List can be directly
"   passed to append(), and it will insert just like :put {reg}.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:register  Name of register.
"* RETURN VALUES:
"   List of lines.
"******************************************************************************
    let l:lines = split(getreg(a:register), '\n', 1)
    if len(l:lines) > 1 && empty(l:lines[-1])
	call remove(l:lines, -1)
    endif
    return l:lines
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
