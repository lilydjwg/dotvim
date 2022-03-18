" ingo/tabpage.vim: Functions for tab page information.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#tabpage#IsBlank( ... )
    if a:0
	let l:tabPageNr = a:1
	let l:currentBufNr = tabpagebuflist(l:tabPageNr)[0]
    else
	let l:tabPageNr = tabpagenr()
	let l:currentBufNr = bufnr('')
    endif

    return (
    \   empty(bufname(l:currentBufNr)) &&
    \   tabpagewinnr(l:tabPageNr, '$') <= 1 &&
    \   getbufvar(l:currentBufNr, '&modified') == 0 &&
    \   empty(getbufvar(l:currentBufNr, '&buftype'))
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
