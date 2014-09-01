" ingo/collections.vim: Functions to operate on collections.
"
" DEPENDENCIES:
"   - ingo/dict.vim autoload script
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.011	15-Oct-2013	Use the extracted ingo#list#AddOrExtend().
"   1.011.010	12-Jul-2013	Make ingo#collections#ToDict() handle empty list
"				items via an optional a:emptyValue argument.
"				This also distinguishes it from
"				ingo#dict#FromKeys().
"				ENH: Handle empty list items in
"				ingo#collections#Unique() and
"				ingo#collections#UniqueStable().
"   1.009.009	25-Jun-2013	Add ingo#collections#Flatten() and
"				ingo#collections#Flatten1().
"				Delegate ingo#collections#ToDict()
"				implementation to ingo#dict#FromKeys().
"				Move ingo#collections#MakeUnique() to
"				ingo/collections/unique.vim.
"   1.001.008	21-Feb-2013	Move to ingo-library. Change case of *#unique*
"				functions.
"	007	09-Nov-2012	Add ingocollections#MakeUnique().
"	006	16-Aug-2012	Add ingocollections#uniqueSorted() and
"				ingocollections#uniqueStable() variants of
"				ingocollections#unique().
"	005	30-Jul-2012	Split off ingocollections#ToDict() from
"				ingocollections#unique(); it is useful on its
"				own.
"	004	25-Jul-2012	Add ingocollections#numsort().
"	003	17-Jun-2011	Add ingocollections#isort().
"	002	11-Jun-2011	Add ingocollections#SplitKeepSeparators().
"	001	08-Oct-2010	file creation

function! ingo#collections#ToDict( list, ... )
"******************************************************************************
"* PURPOSE:
"   Convert a:list to a Dictionary, with each list element becoming a key (and
"   the unimportant value is 1).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List of keys.
"   a:emptyValue    Optional value for items in a:list that yield an empty
"		    string, which cannot be uses as a Dictionary key.
"		    If omitted, empty values are not included in the Dictionary.
"* RETURN VALUES:
"   A new Dictionary with keys taken from a:list.
"* SEE ALSO:
"   ingo#dict#FromKeys() allows to specify a default value (here hard-coded to
"   1), but doesn't handle empty keys.
"******************************************************************************
    let l:dict = {}
    for l:item in a:list
	let l:key = '' . l:item
	if l:key ==# ''
	    if a:0
		let l:dict[a:1] = 1
	    endif
	else
	    let l:dict[l:key] = 1
	endif
    endfor
    return l:dict
endfunction

function! ingo#collections#Unique( list, ... )
"******************************************************************************
"* PURPOSE:
"   Return a list where each element from a:list is contained only once.
"   Equality check is done on the string representation, always case-sensitive.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List of elements; does not need to be sorted.
"   a:emptyValue    Optional value for items in a:list that yield an empty
"		    string. Default is <Nul>.
"* RETURN VALUES:
"   Return the string representation of the unique elements of a:list. The order
"   of returned elements is undetermined. To maintain the original order, use
"   ingo#collections#UniqueStable(). To keep the original elements, use
"   ingo#collections#UniqueSorted(). But this is the fastest function.
"******************************************************************************
    let l:emptyValue = (a:0 ? a:1 : "\<Nul>")
    return map(keys(ingo#collections#ToDict(a:list, l:emptyValue)), 'v:val == l:emptyValue ? "" : v:val')
endfunction
function! ingo#collections#UniqueSorted( list )
"******************************************************************************
"* PURPOSE:
"   Filter the sorted a:list so that each element is contained only once.
"   Equality check is done on the list elements, always case-sensitive.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  Sorted list of elements.
"* RETURN VALUES:
"   The order of returned elements is kept.
"******************************************************************************
    if len(a:list) < 2
	return a:list
    endif

    let l:previousItem = a:list[0]
    let l:result = [a:list[0]]
    for l:item in a:list[1:]
	if l:item !=# l:previousItem
	    call add(l:result, l:item)
	    let l:previousItem = l:item
	endif
    endfor
    return l:result
endfunction
function! ingo#collections#UniqueStable( list, ... )
"******************************************************************************
"* PURPOSE:
"   Filter a:list so that each element is contained only once (in its first
"   occurrence).
"   Equality check is done on the string representation, always case-sensitive.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List of elements; does not need to be sorted.
"   a:emptyValue    Optional value for items in a:list that yield an empty
"		    string. Default is <Nul>.
"* RETURN VALUES:
"   The order of returned elements is kept.
"******************************************************************************
    let l:emptyValue = (a:0 ? a:1 : "\<Nul>")
    let l:itemDict = {}
    let l:result = []
    for l:item in a:list
	let l:key = ('' . l:item ==# '' ? l:emptyValue : l:item)
	if ! has_key(l:itemDict, l:key)
	    let l:itemDict[l:key] = 1
	    call add(l:result, l:item)
	endif
    endfor
    return l:result
endfunction

function! s:add( list, expr, keepempty )
    if ! a:keepempty && empty(a:expr)
	return
    endif
    return add(a:list, a:expr)
endfunction
function! ingo#collections#SplitKeepSeparators( expr, pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Like the built-in |split()|, but keep the separators matched by a:pattern as
"   individual items in the result. Also supports zero-width separators like
"   \zs. (Though for an unconditional zero-width match, this special function
"   would not provide anything that split() doesn't yet provide.)
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr	Text to be split.
"   a:pattern	Regular expression that specifies the separator text that
"		delimits the items.
"   a:keepempty	When the first or last item is empty it is omitted, unless the
"		{keepempty} argument is given and it's non-zero.
"		Other empty items are kept when {pattern} matches at least one
"		character or when {keepempty} is non-zero.
"* RETURN VALUES:
"   List of items.
"******************************************************************************
    let l:keepempty = (a:0 ? a:1 : 0)
    let l:prevIndex = 0
    let l:index = 0
    let l:separator = ''
    let l:items = []

    while ! empty(a:expr)
	let l:index = match(a:expr, a:pattern, l:prevIndex)
	if l:index == -1
	    call s:add(l:items, strpart(a:expr, l:prevIndex), l:keepempty)
	    break
	endif
	let l:item = strpart(a:expr, l:prevIndex, (l:index - l:prevIndex))
	call s:add(l:items, l:item, (l:keepempty || ! empty(l:separator)))

	let l:prevIndex = matchend(a:expr, a:pattern, l:prevIndex)
	let l:separator = strpart(a:expr, l:index, (l:prevIndex - l:index))

	if empty(l:item) && empty(l:separator)
	    " We have a zero-width separator; consume at least one character to
	    " avoid the endless loop.
	    let l:prevIndex = matchend(a:expr, '\_.', l:index)
	    if l:prevIndex == -1
		break
	    endif
	    call add(l:items, strpart(a:expr, l:index, (l:prevIndex - l:index)))
	else
	    call s:add(l:items, l:separator, l:keepempty)
	endif
    endwhile

    return l:items
endfunction

function! ingo#collections#isort( i1, i2 )
"******************************************************************************
"* PURPOSE:
"   Case-insensitive sort function for strings; lowercase comes before
"   uppercase.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   i1, i2  Strings.
"* RETURN VALUES:
"   -1, 0 or 1, as specified by the sort() function.
"******************************************************************************
    if a:i1 ==# a:i2
	return 0
    elseif a:i1 ==? a:i2
	" If only differ in case, choose lowercase before uppercase.
	return a:i1 < a:i2 ? 1 : -1
    else
	" ASCII-ascending while ignoring case.
	return tolower(a:i1) > tolower(a:i2) ? 1 : -1
    endif
endfunction

function! ingo#collections#numsort( i1, i2, ... )
"******************************************************************************
"* PURPOSE:
"   Numerical (through str2nr()) sort function for numbers; text after the
"   number is silently ignored.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   i1, i2  Elements (that are converted to numbers).
"   a:base  Optional base for conversion.
"* RETURN VALUES:
"   -1, 0 or 1, as specified by the sort() function.
"******************************************************************************
    let l:base = (a:0 ? a:1 : 10)
    let [l:i1, l:i2] = [str2nr(a:i1, l:base), str2nr(a:i2, l:base)]
    return l:i1 == l:i2 ? 0 : l:i1 > l:i2 ? 1 : -1
endfunction

function! ingo#collections#Flatten1( list )
    let l:result = []
    for l:item in a:list
	call ingo#list#AddOrExtend(l:result, l:item)
	unlet l:item
    endfor
    return l:result
endfunction
function! ingo#collections#Flatten( list )
    let l:result = []
    for l:item in a:list
	if type(l:item) == type([])
	    call extend(l:result, ingo#collections#Flatten(l:item))
	else
	    call add(l:result, l:item)
	endif
	unlet l:item
    endfor
    return l:result
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
