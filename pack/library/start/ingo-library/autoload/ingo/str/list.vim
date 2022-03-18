" ingo/str/list.vim: Functions for dealing with Strings as Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#str#list#OfCharacters( string )
    return split(a:string, '\zs')
endfunction

function! ingo#str#list#OfBytes( string )
    let l:i = 0
    let l:len = len(a:string)
    let l:list = []
    while l:i < l:len
	call add(l:list, a:string[l:i])
	let l:i += 1
    endwhile

    return l:list
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
