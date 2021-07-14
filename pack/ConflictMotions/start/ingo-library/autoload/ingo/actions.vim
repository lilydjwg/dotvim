" ingo/actions.vim: Functions for flexible action execution.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#actions#GetValExpr()
    return '\w\@<!v:val\w\@!'
endfunction
function! ingo#actions#RenderExCommandWithVal( Action, arguments ) abort
    let l:val = (len(a:arguments) == 1 ? a:arguments[0] : a:arguments)
    if type(l:val) == type([]) || type(l:val) == type({})
	" Avoid "E730: using List as a String" in the substitution.
	let l:val = string(l:val)
    endif

    return substitute(a:Action, '\C' . ingo#actions#GetValExpr(), l:val, 'g')
endfunction

function! ingo#actions#ValueOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    else
	return a:Action
    endif
endfunction
function! ingo#actions#NormalOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    else
	execute 'normal!' a:Action
	return ''
    endif
endfunction
function! ingo#actions#ExecuteOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    else
	execute a:Action
	return ''
    endif
endfunction
function! ingo#actions#ExecuteWithValOrFunc( Action, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Execute a:Action; a Funcref is passed all arguments, else each occurrence of
"   "v:val" is replaced with the single argument / a List of the passed
"   arguments.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be :execute'd.
"   a:arguments Value(s) to be passed to the a:Action Funcref or used for
"		occurrences of "v:val" inside the a:Action expression. The v:val
"		is inserted literally (as a Number, String, List, Dict)!
"* RETURN VALUES:
"   Result of evaluating a:Action, for Ex commands you need to use :return.
"******************************************************************************
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    else
	execute ingo#actions#RenderExCommandWithVal(a:Action, a:000)
    endif
endfunction
function! ingo#actions#EvaluateOrFunc( Action, ... )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Action; a Funcref is passed all arguments, else it is eval()ed.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be eval()ed.
"   a:arguments Value(s) to be passed to the a:Action Funcref (but not the
"		expression; use ingo#actions#EvaluateWithValOrFunc() for that).
"* RETURN VALUES:
"   Result of evaluating a:Action.
"******************************************************************************
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    else
	return eval(a:Action)
    endif
endfunction
function! ingo#actions#EvaluateWithVal( expression, val )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:expression; each occurrence of "v:val" is replaced with a:val,
"   just like in |map()|.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expression    An expression to be eval()ed.
"   a:val           Value to be used for occurrences of "v:val" inside
"		    a:expression.
"* RETURN VALUES:
"   Result of evaluating a:expression.
"******************************************************************************
    return get(map([a:val], a:expression), 0, '')
endfunction
function! ingo#actions#EvaluateWithValOrFunc( Action, ... )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Action; a Funcref is passed all arguments, else each occurrence
"   of "v:val" is replaced with the single argument / a List of the passed
"   arguments.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be eval()ed.
"   a:arguments Value(s) to be passed to the a:Action Funcref or used for
"		occurrences of "v:val" inside the a:Action expression.
"* RETURN VALUES:
"   Result of evaluating a:Action.
"******************************************************************************
    if type(a:Action) == type(function('tr'))
	return call(a:Action, a:000)
    elseif a:0 == 0
	" No arguments have been specified. Remove any occurrence of "v:val"
	" instead of passing an empty list or empty string. This is useful for
	" invoking functions (an expression, not Funcref) with optional
	" arguments.
	return eval(substitute(a:Action, '\C' . ingo#actions#GetValExpr(), '', 'g'))
    else
	let l:val = (a:0 == 1 ? a:1 : a:000)
	return get(map([l:val], a:Action), 0, '')
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
