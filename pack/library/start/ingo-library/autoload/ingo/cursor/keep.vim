" ingo/cursor/keep.vim: Functions to keep the cursor at its current position.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"   - ingo/range.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#cursor#keep#WhileExecuteOrFunc( startLnum, endLnum, Action, ... )
"******************************************************************************
"* PURPOSE:
"   Commands in the executed a:Action do not change the current text position
"   (within the range of a:startLnum,a:endLnum), relative to the current text.
"   This works by temporarily inserting a sentinel character at the current
"   cursor position, and searching for it after the action has executed.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"   Text within the a:startLnum, a:endLnum (adapted to any change in line
"   numbers by a:Action) range does not contain the sentinel value (NUL = ^@).
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startLnum Range of lines that may be affected by a:Action.
"   a:endLnum
"   a:Action    Either a Funcref or Ex commands to be :executed.
"   a:arguments Value(s) to be passed to the a:Action Funcref (but not the
"		Ex commands).
"* RETURN VALUES:
"   Result of evaluating a:Action, for Ex commands you need to use :return.
"******************************************************************************
    let l:endLnum = a:endLnum
    let l:lineNum = line('$')
    let l:save_foldenable = &l:foldenable
    setlocal nofoldenable

    noautocmd execute "normal! i\<C-v>\<C-@>\<Esc>"
    try
	return call('ingo#actions#ExecuteOrFunc', [a:Action] + a:000)
    finally
	let l:addedLineNum = line('$') - l:lineNum
	let l:endLnum += l:addedLineNum

	if ingo#range#IsOutside(line('.'), a:startLnum, l:endLnum)
	    call cursor(a:startLnum, 1)
	endif

	if search("\<C-j>", 'cW', l:endLnum) != 0 || search("\<C-j>", 'bcW', a:startLnum) != 0
	    " Found the sentinel, remove it.
	    noautocmd normal! x
	endif

	let &l:foldenable = l:save_foldenable
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
