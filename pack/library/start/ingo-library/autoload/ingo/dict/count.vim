" ingo/dict/count.vim: Functions for counting with Dictionaries.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/dict.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	24-May-2017	file creation

function! ingo#dict#count#Items( dict, items, ... )
"******************************************************************************
"* PURPOSE:
"   For each item in a:items, create a key with count 1 / increment the value of
"   an existing key in a:dict.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:dict  Dictionary that holds the items -> counts. Need not be empty.
"   a:items List of items to be counted.
"   a:emptyValue    Optional value for items in a:list that yield an empty
"		    string, which (in Vim versions prior to 7.4.1707) cannot be
"		    used as a Dictionary key.
"		    If omitted, empty values are not included in the Dictionary.
"* RETURN VALUES:
"   a:dict
"* SEE ALSO:
"   ingo#collections#ToDict() does not count, just uses a hard-coded value
"   ingo#dict#FromKeys() also does not count but allows to specify a default value
"******************************************************************************
    for l:item in a:items
	if l:item ==# ''
	    if a:0
		let l:item = a:1
	    else
		continue
	    endif
	endif

	if has_key(a:dict, l:item)
	    let a:dict[l:item] += 1
	else
	    let a:dict[l:item] = 1
	endif
    endfor
    return a:dict
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
