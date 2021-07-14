" ingo/buffer.vim: Functions for buffer information.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.006	25-May-2017	Add ingo#buffer#VisibleList().
"   1.025.005	29-Jul-2016	Add ingo#buffer#ExistOtherLoadedBuffers().
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

function! ingo#buffer#IsWritable( ... )
    if ! call('ingo#buffer#IsPersisted', a:000)
	return 0
    endif

    let l:readonly = (a:0 ? getbufvar(a:1, '&readonly') : &l:readonly)
    if l:readonly
	return 0
    endif

    let l:modifiable = (a:0 ? getbufvar(a:1, '&modifiable') : &l:modifiable)
    if ! l:modifiable
	return 0
    endif

    return 1
endfunction

function! ingo#buffer#ExistOtherBuffers( targetBufNr )
    return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:targetBufNr'))
endfunction
function! ingo#buffer#ExistOtherLoadedBuffers( targetBufNr )
    return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && bufloaded(v:val) && v:val != a:targetBufNr'))
endfunction

function! ingo#buffer#IsEmptyVim()
    let l:currentBufNr = bufnr('')
    return ingo#buffer#IsBlank(l:currentBufNr) && ! ingo#buffer#ExistOtherBuffers(l:currentBufNr)
endfunction

function! ingo#buffer#VisibleList( ... )
"******************************************************************************
"* PURPOSE:
"   The result is a List, where each item is the number of the buffer associated
"   with each window in all tab pages / the passed a:range of tab pages. Like
"   |tabpagebuflist()|, but for all / multiple tab pages.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:range Optional range of tab pages to consider. To exclude the current tab
"           page, pass filter(range(tabpagenr('$')), 'v:val != tabpagenr()')
"* RETURN VALUES:
"   List of buffer numbers; may contain duplicates.
"******************************************************************************
    let l:buflist = []
    for l:i in (a:0 ? a:1 : range(1, tabpagenr('$')))
	call extend(l:buflist, tabpagebuflist(l:i))
    endfor
    return l:buflist
endfunction

function! ingo#buffer#NameOrDefault( bufName ) abort
    return (empty(a:bufName) ? '[No Name]' : a:bufName)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
