" ingo/collections/memoized.vim: Functions to operate on memoized collections.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	22-Oct-2014	file creation

let s:memoizedI = {}
let s:memoizedTime = -1
function! ingo#collections#memoized#Mapsort( string, i1, i2, ... )
"******************************************************************************
"* PURPOSE:
"   Like ingo#collections#mapsort(), but caches the mapped result in a temporary
"   Dictionary. This can speed up expensive maps (like using getftime()).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string  Vimscript expression to be evaluated over [a:i1, a:i2] via map().
"   i1, i2  Elements
"   a:options.cacheTimeInSeconds    Number of seconds until the cache is
"				    cleared. To make the cache apply only to the
"				    current sort(), choose a value that's
"				    slightly larger than the largest expected
"				    running time for a comparison.
"   a:options.maxCacheSize          Maximum number of items in the cache before
"				    it is cleared.
"* RETURN VALUES:
"   -1, 0 or 1, as specified by the sort() function.
"   Note: To reverse the sort order, just multiply this function's return value
"   with -1.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})

    if has_key(l:options, 'cacheTimeInSeconds') && localtime() - s:memoizedTime > l:options.cacheTimeInSeconds
	let s:memoizedI = {}
    elseif has_key(l:options, 'maxCacheSize') && len(s:memoizedI) > l:options.maxCacheSize
	let s:memoizedI = {}
    endif

    if has_key(s:memoizedI, a:i1)
	let l:i1 = s:memoizedI[a:i1]
    else
	let l:i1 = map([a:i1], a:string)[0]
	let s:memoizedI[a:i1] = l:i1
    endif
    if has_key(s:memoizedI, a:i2)
	let l:i2 = s:memoizedI[a:i2]
    else
	let l:i2 = map([a:i2], a:string)[0]
	let s:memoizedI[a:i2] = l:i2
    endif

    let s:memoizedTime = localtime()

    return l:i1 == l:i2 ? 0 : l:i1 > l:i2 ? 1 : -1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
