" ingo/query/fromlist.vim: Functions for querying elements from a list.
"
" DEPENDENCIES:
"   - ingo/query/confirm.vim autoload script
"   - ingo/query/get.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	03-Jun-2014	file creation

function! ingo#query#fromlist#Query( what, list, ... )
"******************************************************************************
"* PURPOSE:
"   Query for one entry from a:list; elements can be selected by accelerator key
"   or the number of the element.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Description of what is queried.
"   a:list  List of elements. Accelerators can be preset by prefixing with "&".
"   a:defaultIndex  Default element (which will be chosed via <Enter>); -1 for
"		    no default.
"* RETURN VALUES:
"   Index of the chosen element of a:list, or -1 if the query was aborted.
"******************************************************************************
    let l:defaultIndex = (a:0 ? a:1 : -1)
    let l:confirmList = ingo#query#confirm#AutoAccelerators(copy(a:list), -1)
    let l:accelerators = map(copy(l:confirmList), 'matchstr(v:val, "&\\zs.")')
    let l:list = []
    for l:i in range(len(l:confirmList))
	call add(l:list, (l:i + 1) . ':' . substitute(l:confirmList[l:i], '&\(.\)', (l:i == l:defaultIndex ? '[\1]' : '(\1)'), ''))
    endfor

    echohl Question
    echomsg printf('Select %s via [count] or (l)etter: %s ?', a:what, join(l:list, ', '))
    echohl None

    let l:choice = ingo#query#get#Char()
    let l:count = index(l:accelerators, l:choice, 0, 1) + 1
    if l:count == 0
	let l:count = str2nr(l:choice)
	if l:count < 1 || l:count > len(a:list)
	    redraw | echo ''
	    return -1
	endif
    endif
    return l:count - 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
