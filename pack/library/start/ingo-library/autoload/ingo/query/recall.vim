" ingo/query/recall.vim: Functions to recall a value from a list.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/query/get.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	10-Jan-2017	file creation

function! ingo#query#recall#Query( title, list, isReverse )
"******************************************************************************
"* PURPOSE:
"   Query one entry from a:list by number.
"* SEE ALSO:
"   ingo#query#fromlist#Query() provides an alternative means to query one entry
"   from a (longer) list.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:title Text describing the list elements; will be printed as a table
"	    header.
"   a:list  List of elements. Each element can also be a List of Strings (which
"	    are simply concatenated) or a List of [part, hlgroup] Pairs
"	    highlighted through ingo#msg#ColoredMsg().
"   a:isReverse Flag whether the first element from a:list comes last in the
"		table, which makes it faster to visually parse a long list of
"		MRU elements.
"* RETURN VALUES:
"   List index, or -2 if a:list is empty, or -1 if an invalid number was
"   chosen, or the query aborted via a non-numeric choice.
"******************************************************************************
    let l:len = len(a:list)
    if l:len == 0
	return -2
    endif

    echohl Title
    echo '      #  ' . a:title
    echohl None

    for l:i in (a:isReverse ? range(l:len - 1, 0, -1) : range(l:len))
	call call('ingo#msg#ColoredMsg', [printf('%7d  ', l:i + 1)] + ingo#list#Make(a:list[l:i]))
    endfor
    echo 'Type number (<Enter> cancels): '
    let l:choice = ingo#query#get#Number(l:len)
    return (l:choice < 1 || l:choice > l:len ? -1 : l:choice - 1)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
