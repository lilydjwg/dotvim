" ingo/collections/permute.vim: Functions to permute a List.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.001	27-Jun-2014	file creation

function! ingo#collections#permute#Shuffle( list, Rand )
    " Fisher-Yates shuffle
    let [l:list, l:len] = [a:list, len(a:list)]

    let i = l:len
    while i > 0
        let i -= 1
        let j = a:Rand() * i % l:len
        if i == j
            continue
        endif
        let l:swap = l:list[i]
        let l:list[i] = list[j]
        let l:list[j] = l:swap
    endwhile

    return l:list
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
