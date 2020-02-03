" ingo/file.vim: Functions to work on files not loaded into Vim.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

if ! exists('g:IngoLibrary_FileCacheMaxSize')
    let g:IngoLibrary_FileCacheMaxSize = 1048576
endif

let s:cachedFileContents = {}
let s:cachedFileInfo = {}
function! s:GetCacheSize()
    return ingo#collections#Reduce(
    \   map(values(s:cachedFileInfo), 'v:val.fsize'),
    \   'v:val[0] + v:val[1]',
    \   0
    \)
endfunction
function! ingo#file#GetCachedFilesByAge()
    return map(sort(items(s:cachedFileInfo), 's:SortByATime'), 'v:val[0]')
endfunction
function! s:GetOldestElement()
    return ingo#file#GetCachedFilesByAge()[0]
endfunction
function! s:SortByATime( i1, i2 )
    return ingo#collections#SortOnOneAttribute('atime', a:i1[1], a:i2[1])
endfunction
function! s:AddToCache( filespec, lines, ftime, fsize )
    if a:fsize > g:IngoLibrary_FileCacheMaxSize
	" Too large for the cache.
	return 0
    endif

    while len(s:cachedFileInfo) > 0 && g:IngoLibrary_FileCacheMaxSize - s:GetCacheSize() < a:fsize
	" Need to evict old elements from the cache to make room.
	call s:RemoveFromCache(s:GetOldestElement())
    endwhile

    let s:cachedFileContents[a:filespec] = copy(a:lines)
    let s:cachedFileInfo[a:filespec] = {'atime': localtime(), 'ftime': a:ftime, 'fsize': a:fsize}
endfunction
function! s:UseFromCache( filespec )
    let s:cachedFileInfo[a:filespec].atime = localtime()
    return s:cachedFileContents[a:filespec]
endfunction
function! s:IsCached( filespec, ftime )
    return has_key(s:cachedFileInfo, a:filespec) && s:cachedFileInfo[a:filespec].ftime == a:ftime
endfunction
function! s:RemoveFromCache( filespec )
    if has_key(s:cachedFileInfo, a:filespec)
	unlet! s:cachedFileInfo[a:filespec]
    endif
    if has_key(s:cachedFileContents, a:filespec)
	unlet! s:cachedFileContents[a:filespec]
    endif
endfunction

function! ingo#file#GetLines( filespec )
"******************************************************************************
"* PURPOSE:
"   Load the contents of a:filespec and return the (possibly cached) lines.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Text file to be read. File contents must be in Vim's 'encoding'.
"* RETURN VALUES:
"   Empty List if the file doesn't exist or is empty. List of lines otherwise.
"******************************************************************************
    let l:filespec = ingo#fs#path#Canonicalize(a:filespec, 1)
    let l:ftime = getftime(l:filespec)

    if l:ftime == -1
	" File doesn't exist (any longer).
	call s:RemoveFromCache(l:filespec)
	return []
    elseif s:IsCached(l:filespec, l:ftime)
	" File is in cache and hasn't been changed.
	return s:UseFromCache(l:filespec)
    endif

    try
	let l:lines = readfile(l:filespec)
	call s:AddToCache(l:filespec, l:lines, l:ftime, getfsize(l:filespec))
	return l:lines
    catch /^Vim\%((\a\+)\)\=:E484/ " E484: Can't open file
	call s:RemoveFromCache(l:filespec)
	return []
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
