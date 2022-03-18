" ingo/escape/mapping.vim: Additional escapings of mappings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#escape#mapping#keys( keys ) abort
    let l:keys = a:keys
    let l:keys = substitute(l:keys, ' ', '<Space>', 'g')
    let l:keys = substitute(l:keys, '\', '<Bslash>', 'g')
    let l:keys = substitute(l:keys, '|', '<Bar>', 'g')
    return l:keys
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
