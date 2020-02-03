" ingo/query.vim: Functions for user queries.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.027.004	27-Sep-2016	Expose ingo#query#StripAccellerator().
"   1.025.003	27-Jan-2016	Refactoring: Factor out ingo#query#Question().
"   1.019.002	20-May-2014	confirm() automatically presets the first
"				character with an accelerator when no "&"
"				present; do that for s:EchoEmulatedConfirm(),
"				too.
"   1.019.001	30-Apr-2014	file creation from
"				autoload/IndentConsistencyCop.vim and
"				autoload/DropQuery.vim
let s:save_cpo = &cpo
set cpo&vim

function! ingo#query#Question( msg )
    echohl Question
    echomsg a:msg
    echohl None
endfunction


function! ingo#query#StripAccellerator( choice )
    return substitute(a:choice, '&', '', 'g')
endfunction
function! s:EchoEmulatedConfirm( msg, choices, defaultIndex )
    let l:defaultChoice = (a:defaultIndex > 0 ? get(a:choices, a:defaultIndex - 1) : '')
    echo a:msg
    echo join(map(copy(a:choices), 'substitute(v:val, "\\%(^\\%(.*&.*$\\)\\@!\\|&\\)\\(.\\)", (v:val ==# l:defaultChoice ? "[\\1]" : "(\\1)"), "g")'), ', ') . ': '
endfunction

function! ingo#query#Confirm( msg, ... )
"******************************************************************************
"* PURPOSE:
"   Drop-in replacement for confirm() that supports "headless mode", i.e.
"   bypassing the actual dialog so that no user intervention is necessary (in
"   automated tests).
"
"* ASSUMPTIONS / PRECONDITIONS:
"   The headless mode is activated by defining a List of choices (either
"   numerical return values of confirm(), or the choice text without the
"   shortcut key "&") in g:IngoLibrary_ConfirmChoices. Each invocation of this
"   function removes the first element from that List and returns it.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   See confirm().
"* RETURN VALUES:
"   See confirm().
"******************************************************************************
    if exists('g:IngoLibrary_ConfirmChoices') && len(g:IngoLibrary_ConfirmChoices) > 0
	" Headless mode: Bypass actual confirm so that no user intervention is
	" necesary.

	let l:choices = (a:0 ? split(a:1, '\n', 1) : ['&Ok'])
	let l:plainChoices = map(copy(l:choices), 'ingo#query#StripAccellerator(v:val)')

	" Emulate the console output of confirm(), so that it looks for a test
	" driver as if it were real.
	let l:defaultIndex = (a:0 >= 2 ? a:2 : 0)
	call s:EchoEmulatedConfirm(a:msg, l:choices, l:defaultIndex)

	" Return predefined choice.
	let l:choice = remove(g:IngoLibrary_ConfirmChoices, 0)
	return (type(l:choice) == type(0) ?
	\   l:choice :
	\   (l:choice == '' ?
	\       0 :
	\       index(l:plainChoices, l:choice) + 1
	\   )
	\)
    endif
    return call('confirm', [a:msg] + a:000)
endfunction

function! ingo#query#ConfirmAsText( msg, choices, ... )
"******************************************************************************
"* PURPOSE:
"   Replacement for confirm() that returns choices by name, not by index, and
"   supports "headless mode", i.e. bypassing the actual dialog so that no user
"   intervention is necessary (in automated tests).
"
"* ASSUMPTIONS / PRECONDITIONS:
"   The headless mode is activated by defining a List of choices (either
"   numerical return values of confirm(), or the choice text without the
"   shortcut key "&") in g:IngoLibrary_ConfirmChoices. Each invocation of this
"   function removes the first element from that List and returns it.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:msg	Dialog text.
"   a:choices	List of choices (not a newline-delimited String as in
"		|confirm()|). Set the shortcut key by prepending '&'.
"   a:default	Default choice text. Either number (0 for no default, (index +
"		1) for choice) or choice text; omit any shortcut key '&' there.
"   a:type      Optional type of dialog; see |confirm()|.
"* RETURN VALUES:
"   Choice text without the shortcut key '&'. Empty string if the dialog was
"   aborted.
"******************************************************************************
    let l:plainChoices = map(copy(a:choices), 'ingo#query#StripAccellerator(v:val)')

    let l:confirmArgs = [a:msg, join(a:choices, "\n")]
    if a:0
	call add(l:confirmArgs, (type(a:1) == type(0) ? a:1 : max([index(l:plainChoices, a:1) + 1, 0])))
	call extend(l:confirmArgs, a:000[1:])
    endif

    if exists('g:IngoLibrary_ConfirmChoices') && len(g:IngoLibrary_ConfirmChoices) > 0
	" Headless mode: Bypass actual confirm so that no user intervention is
	" necesary.

	" Emulate the console output of confirm(), so that it looks for a test
	" driver as if it were real.
	let l:defaultIndex = get(l:confirmArgs, 2, 0)
	call s:EchoEmulatedConfirm(a:msg, a:choices, l:defaultIndex)

	" Return predefined choice.
	let l:choice = remove(g:IngoLibrary_ConfirmChoices, 0)
	return (type(l:choice) == type(0) ?
	\   (l:choice == 0 ?
	\       '' :
	\       ingo#query#StripAccellerator(get(a:choices, l:choice - 1, ''))
	\   ) :
	\   l:choice
	\)
    endif
    let l:index = call('confirm', l:confirmArgs)
    return (l:index > 0 ? get(l:plainChoices, l:index - 1, '') : '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
