" ingo/query/confirm.vim: Functions for building choices for confirm().
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:acceleratorPattern = '[[:alnum:]]'
function! ingo#query#confirm#AutoAccelerators( choices, ... )
"******************************************************************************
"* PURPOSE:
"   Automatically add unique accelerators (&Accelerator) for the passed
"   a:choices, to be used in confirm(). Considers already existing ones.
"   Tries to assign to the first (possible) letter with priority.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Modifies a:choices.
"* INPUTS:
"   a:choices   List of choices where the accelerators should be inserted.
"   a:defaultChoice Number (i.e. index + 1) of the default in a:choices. It is
"		    assumed that this item does not need an accelerator (in the
"		    GUI dialog). Pass -1 if there's no default (so that all
"		    items get accelerators).
"* RETURN VALUES:
"   Modified a:choices.
"******************************************************************************
    let l:isGui = (has('gui_running') && &guioptions !~# 'c')
    let l:defaultChoiceIdx = (a:0 ? a:1 - 1 : 0)
    let l:usedAccelerators = filter(
    \   map(
    \       copy(a:choices),
    \       'tolower(matchstr(v:val, "\\C&\\zs" . s:acceleratorPattern))',
    \   ),
    \   '! empty(v:val)'
    \)

    if ! l:isGui && l:defaultChoiceIdx >= 0 && a:choices[l:defaultChoiceIdx] !~# '&.'
	" When no GUI dialog is used, the default choice automatically gets an
	" accelerator, so don't assign that one to avoid masking another choice.
	call add(l:usedAccelerators, matchstr(a:choices[l:defaultChoiceIdx], '^.'))
    endif

    call   map(a:choices, 'v:key == l:defaultChoiceIdx ? v:val : s:AddAccelerator(l:usedAccelerators, v:val, 1)')
    return map(a:choices, 'v:key == l:defaultChoiceIdx ? v:val : s:AddAccelerator(l:usedAccelerators, v:val, 0)')
endfunction
function! s:AddAccelerator( usedAccelerators, value, isWantFirstCharacter )
    if a:value =~# '&' . s:acceleratorPattern
	return a:value
    endif

    if a:isWantFirstCharacter
	let l:candidates = ingo#list#NonEmpty([tolower(matchstr(a:value, s:acceleratorPattern))])
    else
	let l:candidates = split(
	\   tolower(substitute(a:value, '\%(' . s:acceleratorPattern . '\)\@!.', '', 'g')),
	\   '\zs'
	\)
    endif

    for l:candidate in l:candidates
	if index(a:usedAccelerators, l:candidate) == -1
	    call add(a:usedAccelerators, l:candidate)
	    return substitute(a:value, '\V\c' . escape(l:candidate, '\'), '\&&', '')
	endif
    endfor
    return a:value
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
