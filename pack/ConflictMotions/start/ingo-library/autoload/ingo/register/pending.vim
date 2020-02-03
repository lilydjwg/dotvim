" ingo/register/pending.vim: Functions to execute commands while keeping the pending register.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#register#pending#ExecuteOrFunc( Action, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Commands in the executed a:Action do not clobber a pending v:register.
"   This is necessary when a custom operator (that considers the passed
"   register) is working on a custom text object that uses :normal; those
"   commands reset a register passed to the operator, so it gets lost.
"   Cp. https://vi.stackexchange.com/questions/20322/how-to-pass-vregister-to-custom-operator-when-working-on-custom-text-object
"* USAGE:
"   Instead of invoking a function (using :normal) / Ex commandline (that has
"   :normal) as part of the :onoremap, pass it (and any function arguments) to
"   this function.
"       onoremap <silent> af :<C-u>call MyTextObject('a', 0)<CR>
"   becomes
"       onoremap <silent> af :<C-u>call ingo#register#pending#ExecuteOrFunc(function('MyTextObject'), 'a', 0)<CR>
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
    let l:save_register = v:register
    try
	return call('ingo#actions#ExecuteOrFunc', [a:Action] + a:000)
    finally
	execute 'normal! "' . l:save_register
    endtry
endfunction

function! ingo#register#pending#Normal( commands ) abort
"******************************************************************************
"* PURPOSE:
"   Commands in the executed normal mode a:commands do not clobber a pending
"   v:register.
"   This is necessary when a custom operator (that considers the passed
"   register) is working on a custom text object that uses :normal; those
"   commands reset a register passed to the operator, so it gets lost.
"   Cp. https://vi.stackexchange.com/questions/20322/how-to-pass-vregister-to-custom-operator-when-working-on-custom-text-object
"* USAGE:
"   Instead of invoking :normal! as part of the :onoremap, pass its command
"   argument to this function.
"	onoremap iV :<C-u>normal! HVL<CR>
"   becomes
"       onoremap iV :<C-u>call ingo#register#pending#NormalBang('HVL')<CR>
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
    let l:save_register = v:register
    execute 'normal' a:commands
    execute 'normal! "' . l:save_register
endfunction
function! ingo#register#pending#NormalBang( commands ) abort
    let l:save_register = v:register
    execute 'normal!' a:commands
    execute 'normal! "' . l:save_register
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
