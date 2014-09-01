" ingo/dict.vim: Functions for creating Dictionaries.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.002	16-Jan-2014	Add ingo#dict#AddMirrored(), and also add
"				optional a:isEnsureUniqueness flag to
"				ingo#dict#Mirror().
"   1.016.002	23-Dec-2013	Add ingo#dict#Mirror().
"   1.009.001	21-Jun-2013	file creation

function! ingo#dict#FromItems( items )
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a list of [key, value] items, as returned by
"   |items()|.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:items List of [key, value] items.
"* RETURN VALUES:
"   A new Dictionary.
"******************************************************************************
    let l:dict = {}
    for [l:key, l:val] in a:items
	let l:dict[l:key] = l:val
    endfor
    return l:dict
endfunction

function! ingo#dict#FromKeys( keys, defaultValue )
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a:keys, all having a:defaultValue.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:keys  The keys of the Dictionary; must not be empty.
"   a:defaultValue  The value for each of the generated keys.
"* RETURN VALUES:
"   A new Dictionary with keys taken from a:keys and a:defaultValue.
"* SEE ALSO:
"   ingo#collections#ToDict() handles empty key values, but uses a hard-coded
"   default value.
"******************************************************************************
    let l:dict = {}
    for l:key in a:keys
	let l:dict[l:key] = a:defaultValue
    endfor
    return l:dict
endfunction

function! ingo#dict#Mirror( dict, ... )
"******************************************************************************
"* PURPOSE:
"   Turn all values of a:dict into keys, and vice versa.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:dict  Dictionary. It is assumed that all values are non-empty and of
"	    String or Number type (so that they can be coerced into the String
"	    type of the Dictionary key).
"   a:isEnsureUniqueness    Optional flag whether a ValueNotUnique should be
"			    thrown if an equal value was already found. By
"			    default, the last value (in the arbitrary item()
"			    order) overrides previous ones.
"* RETURN VALUES:
"   Returns a new, mirrored Dictionary.
"******************************************************************************
    let l:isEnsureUniqueness = (a:0 && a:1)
    let l:dict = {}
    for [l:key, l:value] in items(a:dict)
	if l:isEnsureUniqueness
	    if has_key(l:dict, l:value)
		throw 'Mirror: ValueNotUnique: ' . l:value
	    endif
	endif
	let l:dict[l:value] = l:key
    endfor
    return l:dict
endfunction
function! ingo#dict#AddMirrored( dict, ... )
"******************************************************************************
"* PURPOSE:
"   Also define all values in a:dict as keys (with their keys as values).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:dict  Dictionary. It is assumed that all values are non-empty and of
"	    String or Number type (so that they can be coerced into the String
"	    type of the Dictionary key).
"   a:isEnsureUniqueness    Optional flag whether a ValueNotUnique should be
"			    thrown if an equal value was already found. By
"			    default, the last value (in the arbitrary item()
"			    order) overrides previous ones.
"* RETURN VALUES:
"   Returns the original a:dict with added reversed entries.
"******************************************************************************
    let l:isEnsureUniqueness = (a:0 && a:1)
    for [l:key, l:value] in items(a:dict)
	if l:isEnsureUniqueness
	    if has_key(l:dict, l:value)
		throw 'AddMirrored: ValueNotUnique: ' . l:value
	    endif
	endif
	let a:dict[l:value] = l:key
    endfor
    return a:dict
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
