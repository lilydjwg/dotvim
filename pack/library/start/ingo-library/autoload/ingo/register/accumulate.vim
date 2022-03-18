" accumulate.vim: Functions for accumulating text in an uppercase register.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#register#accumulate#ExecuteOrFunc( register, Action, ... )
"******************************************************************************
"* PURPOSE:
"   Commands in the executed a:Action can append to any a:register; a temporary
"   uppercase register will be used as an intermediary if necessary.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Any text appended to the uppercase register will be placed into a:register.
"* INPUTS:
"   a:register  Register that will take the accumulated text.
"   a:Action    Either a Funcref or Ex commands to be :executed. For Ex
"               commands, each occurrence of "v:val" is replaced with the
"               uppercase register.
"   a:arguments Value(s) to be passed to the a:Action Funcref (but not the
"		Ex commands); the actual uppercase register will be passed as an
"		additional first argument.
"* RETURN VALUES:
"   Result of evaluating a:Action, for Ex commands you need to use :return.
"******************************************************************************
    if a:register =~# '^\a$'
	let l:accumulator = a:register
    elseif a:register ==# '_'
	let l:accumulator = a:register
    else
	let l:accumulator = 'z'
	let l:save_reg = getreg(l:accumulator)
	let l:save_regmode = getregtype(l:accumulator)
    endif
    if l:accumulator =~# '^\l$'
	call setreg(l:accumulator, '', 'v')
    endif

    try
	return call('ingo#actions#ExecuteWithValOrFunc', [a:Action, toupper(l:accumulator)] + a:000)
    finally
	if exists('l:save_reg')
	    let l:accumulatedText = getreg(l:accumulator)
	    call setreg(l:accumulator, l:save_reg, l:save_regmode)
	    call setreg(a:register, l:accumulatedText)
	endif

	if l:accumulator =~# '^\l$'
	    " When appending lines to an empty register, an initial newline
	    " is kept. We don't want that.
	    call setreg(a:register, substitute(getreg(a:register), '^\n', '', ''))
	endif
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
