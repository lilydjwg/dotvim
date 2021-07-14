" ingo/change/processed.vim: Functions for processing changes.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#change#processed#NetChange( ... ) abort
    let l:change = (a:0 ? a:1 : @.)
    let l:previousChange = ''
    while l:change !=# l:previousChange
	let l:previousChange = l:change
	let l:change = substitute(l:change, "[^\<BS>]\<BS>", '', 'g')
    endwhile

    return l:change
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
