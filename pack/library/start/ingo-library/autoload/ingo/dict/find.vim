" ingo/dict/find.vim: Functions for finding keys that match a value in a Dictionary.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	29-May-2014	file creation

function! s:Find( isAll, dict, value, ... )
    let l:resultKeys = []

    let l:keys = keys(a:dict)
    if a:0
	let l:keys = (empty(a:1) ? sort(l:keys) : sort(l:keys, a:1))
    endif

    for l:key in l:keys
	if a:dict[l:key] ==# a:value
	    if a:isAll
		call add(l:resultKeys, l:key)
	    else
		return l:key
	    endif
	endif
    endfor

    return l:resultKeys
endfunction

function! ingo#dict#find#FirstKey( dict, value, ... )
"******************************************************************************
"* PURPOSE:
"   Find the first key in a:dict that has a:value.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:dict  Dictionary.
"   a:value Value to search.
"   a:func  Optional function name / Funcref to sort the keys of a:dict. If 0 or
"	    '', uses default sort().
"* RETURN VALUES:
"   key of a:dict, or [] to indicate no matching keys.
"******************************************************************************
    return call('s:Find', [0, a:dict, a:value] + a:000)
endfunction

function! ingo#dict#find#Keys( dict, value, ... )
"******************************************************************************
"* PURPOSE:
"   Find all keys in a:dict that have a:value.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:dict  Dictionary.
"   a:value Value to search.
"   a:func  Optional function name / Funcref to sort the keys of a:dict. If 0 or
"	    '', uses default sort().
"* RETURN VALUES:
"   List of keys of a:dict, or [] to indicate no matching keys.
"******************************************************************************
    return call('s:Find', [1, a:dict, a:value] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
