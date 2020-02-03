" ingo/dict.vim: Functions for creating Dictionaries.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#dict#Make( val, defaultKey, ... )
"******************************************************************************
"* PURPOSE:
"   Ensure that the passed a:val is a Dict; if not, wrap it in one, with
"   a:defaultKey as the key.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:val   Arbitrary value of arbitrary type.
"   a:defaultKey            Key for a:val if it's not a Dict yet.
"   a:isCopyOriginalDict    Optional flag; when set, an original a:val Dict is
"			    copied before returning.
"* RETURN VALUES:
"   Dict; either the original one or a new one containing a:defaultKey : a:val.
"******************************************************************************
    return (type(a:val) == type({}) ? (a:0 && a:1 ? copy(a:val) : a:val) : {a:defaultKey : a:val})
endfunction

function! ingo#dict#FromItems( items, ... )
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
"   a:isEnsureUniqueness    Optional flag whether a KeyNotUnique should be
"			    thrown if an equal key was already found. By
"			    default, the last key (in the arbitrary item()
"			    order) overrides previous ones.
"* RETURN VALUES:
"   A new Dictionary.
"******************************************************************************
    let l:isEnsureUniqueness = (a:0 && a:1)
    let l:dict = {}
    for [l:key, l:val] in a:items
	if l:isEnsureUniqueness
	    if has_key(l:dict, l:key)
		throw 'Mirror: KeyNotUnique: ' . l:key
	    endif
	endif
	let l:dict[l:key] = l:val
    endfor
    return l:dict
endfunction

function! ingo#dict#FromKeys( keys, ValueExtractor )
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a:keys, with the key taken from the List
"   elements, and the value obtained through a:KeyExtractor (which can be a
"   constant default).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:keys  List of keys for the Dictionary.
"   a:ValueExtractor    Funcref that is passed a value and is expected to return
"                       a value.
"                       Or a static default value for each of the generated keys.
"* RETURN VALUES:
"   A new Dictionary with keys taken from a:keys and values extracted via /
"   provided by a:ValueExtractor.
"* SEE ALSO:
"   ingo#collections#ToDict() handles empty key values, but uses a hard-coded
"   default value.
"   ingo#dict#count#Items() also creates a Dict from a List, and additionally
"   counts the unique values.
"******************************************************************************
    let l:isFuncref = (type(a:ValueExtractor) == type(function('tr')))
    let l:dict = {}
    for l:key in a:keys
	let l:val = (l:isFuncref ?
	\   call(a:ValueExtractor, [l:key]) :
	\   a:ValueExtractor
	\)
	let l:dict[l:key] = l:val
    endfor
    return l:dict
endfunction

function! ingo#dict#FromValues( KeyExtractor, values ) abort
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a:values, with the value taken from the List
"   elements, and the key obtained through a:KeyExtractor.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:values    List of values for the Dictionary.
"   a:KeyExtractor  Funcref that is passed a value and is expected to return a
"                   (unique) key.
"* RETURN VALUES:
"   A new Dictionary with values taken from a:values and keys extracted through
"   a:KeyExtractor.
"******************************************************************************
    let l:dict = {}
    for l:val in a:values
	let l:key = call(a:KeyExtractor, [l:val])
	let l:dict[l:key] = l:val
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
"	    Alternatively, a list of [key, value] items can be passed (to
"	    influence which key from equal values is used).
"   a:isEnsureUniqueness    Optional flag whether a ValueNotUnique should be
"			    thrown if an equal value was already found. By
"			    default, the last value (in the arbitrary item()
"			    order) overrides previous ones.
"* RETURN VALUES:
"   Returns a new, mirrored Dictionary.
"******************************************************************************
    let l:isEnsureUniqueness = (a:0 && a:1)
    let l:dict = {}
    for [l:key, l:value] in (type(a:dict) == type({}) ? items(a:dict) : a:dict)
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
"	    Alternatively, a list of [key, value] items can be passed (to
"	    influence which key from equal values is used).
"   a:isEnsureUniqueness    Optional flag whether a ValueNotUnique should be
"			    thrown if an equal value was already found. By
"			    default, the last value (in the arbitrary item()
"			    order) overrides previous ones.
"* RETURN VALUES:
"   Returns the original a:dict with added reversed entries.
"******************************************************************************
    let l:isEnsureUniqueness = (a:0 && a:1)
    for [l:key, l:value] in (type(a:dict) == type({}) ? items(a:dict) : a:dict)
	if l:isEnsureUniqueness
	    if has_key(l:dict, l:value)
		throw 'AddMirrored: ValueNotUnique: ' . l:value
	    endif
	endif
	let a:dict[l:value] = l:key
    endfor
    return a:dict
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
