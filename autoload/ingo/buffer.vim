" ingo/buffer.vim: Functions for buffer information.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.015.004	18-Nov-2013	Make buffer argument of ingo#buffer#IsBlank()
"				optional, defaulting to the current buffer.
"				Allow use of ingo#buffer#IsEmpty() with other
"				buffers.
"   1.014.003	07-Oct-2013	Add ingo#buffer#IsPersisted(), taken from
"				autoload/ShowTrailingWhitespace/Filter.vim.
"   1.010.002	08-Jul-2013	Add ingo#buffer#IsEmpty().
"   1.006.001	29-May-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#buffer#IsEmpty( ... )
    if a:0
	return (getbufline(a:1, 2) == [] && empty(get(getbufline(a:1, 1), 0, '')))
    else
	return (line('$') == 1 && empty(getline(1)))
    endif
endfunction

function! ingo#buffer#IsBlank( ... )
    let l:bufNr = (a:0 ? a:1 : '')
    return (empty(bufname(l:bufNr)) &&
    \ getbufvar(l:bufNr, '&modified') == 0 &&
    \ empty(getbufvar(l:bufNr, '&buftype'))
    \)
endfunction

function! ingo#buffer#IsPersisted( ... )
    let l:bufType = (a:0 ? getbufvar(a:1, '&buftype') : &l:buftype)
    return (empty(l:bufType) || l:bufType ==# 'acwrite')
endfunction

function! ingo#buffer#ExistOtherBuffers( targetBufNr )
    return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:targetBufNr'))
endfunction

function! ingo#buffer#IsEmptyVim()
    let l:currentBufNr = bufnr('')
    return ingo#buffer#IsBlank(l:currentBufNr) && ! ingo#buffer#ExistOtherBuffers(l:currentBufNr)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
