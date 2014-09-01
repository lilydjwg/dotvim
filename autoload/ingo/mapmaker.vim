" ingo/mapmaker.vim: Functions that create mappings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.001	17-Apr-2013	file creation from ingointegration.vim

function! s:OpfuncExpression( opfunc )
    let &opfunc = a:opfunc

    let l:keys = 'g@'

    if ! &l:modifiable || &l:readonly
	" Probe for "Cannot make changes" error and readonly warning via a no-op
	" dummy modification.
	" In the case of a nomodifiable buffer, Vim will abort the normal mode
	" command chain, discard the g@, and thus not invoke the operatorfunc.
	let l:keys = ":call setline('.', getline('.'))\<CR>" . l:keys
    endif

    return l:keys
endfunction
function! ingo#mapmaker#OperatorMappingForRangeCommand( mapArgs, mapKeys, rangeCommand )
"******************************************************************************
"* PURPOSE:
"   Define a custom operator mapping "\xx{motion}" (where \xx is a:mapKeys) that
"   allows a [count] before and after the operator and supports repetition via
"   |.|.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   Checks for a 'nomodifiable' or 'readonly' buffer and forces the proper Vim
"   error / warning, so it assumes that a:rangeCommand mutates the buffer.
"
"* EFFECTS / POSTCONDITIONS:
"   Defines a normal mode mapping for a:mapKeys.
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping.
"   a:mapKeys	Mapping key [sequence].
"   a:rangeCommand  Custom Ex command which takes a [range].
"
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:cnt = 0
    while 1
	let l:rangeCommandOperator = printf('Range%s%sOperator', matchstr(a:rangeCommand, '\w\+'), (l:cnt ? l:cnt : ''))
	if ! exists('*s:' . l:rangeCommandOperator)
	    break
	endif
	let l:cnt += 1
    endwhile

    execute printf("
    \	function! s:%s( type )\n
    \	    execute \"'[,']%s\"\n
    \	endfunction\n",
    \	l:rangeCommandOperator,
    \	a:rangeCommand
    \)

    execute 'nnoremap <expr>' a:mapArgs a:mapKeys '<SID>OpfuncExpression(''<SID>' . l:rangeCommandOperator . ''')'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
