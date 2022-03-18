" ingo/collections/recursive.vim: Recursively map a data structure.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#collections#recursive#map( expr1, expr2 )
    return s:Map(0, a:expr1, a:expr2)
endfunction
function! ingo#collections#recursive#MapWithCopy( expr1, expr2 )
    return s:Map(1, copy(a:expr1), a:expr2)
endfunction
function! s:Map( isCopy, expr1, expr2 )
    return map(a:expr1, 's:RecursiveMap(a:isCopy, v:val, a:expr2)')
endfunction
function! s:RecursiveMap( isCopy, value, expr2 )
    let l:value = (a:isCopy ? copy(a:value) : a:value)

    if type(a:value) == type([]) || type(a:value) == type({})
	return s:Map(a:isCopy, l:value, a:expr2)
    else
	return map([l:value], a:expr2)[0]
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
