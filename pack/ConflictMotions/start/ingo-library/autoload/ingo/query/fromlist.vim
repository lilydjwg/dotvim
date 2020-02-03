" ingo/query/fromlist.vim: Functions for querying elements from a list.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/query.vim autoload script
"   - ingo/query/confirm.vim autoload script
"   - ingo/query/get.vim autoload script
"   - ingo/query/recall.vim autoload script
"
" Copyright: (C) 2014-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#query#fromlist#RenderList( list, defaultIndex, formatString )
    let l:result = []
    for l:i in range(len(a:list))
	call add(l:result,
	\   printf(a:formatString, l:i + 1) .
	\   substitute(a:list[l:i], '&\(.\)', (l:i == a:defaultIndex ? '[\1]' : '(\1)'), '')
	\)
    endfor
    return l:result
endfunction
function! ingo#query#fromlist#Query( what, list, ... )
"******************************************************************************
"* PURPOSE:
"   Query for one entry from a:list; elements can be selected by accelerator key
"   or the number of the element. Supports "headless mode", i.e. bypassing the
"   actual dialog so that no user intervention is necessary (in automated
"   tests).
"* SEE ALSO:
"   ingo#query#recall#Query() provides an alternative means to query one
"   (longer) entry from a list.
"* ASSUMPTIONS / PRECONDITIONS:
"   The headless mode is activated by defining a List of choices (either
"   numerical return values of confirm(), or the choice text without the
"   shortcut key "&") in g:IngoLibrary_QueryChoices. Each invocation of this
"   function removes the first element from that List and returns it.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Description of what is queried.
"   a:list  List of elements. Accelerators can be preset by prefixing with "&".
"   a:defaultIndex  Default element (which will be chosen via <Enter>); -1 for
"		    no default.
"* RETURN VALUES:
"   Index of the chosen element of a:list, or -1 if the query was aborted.
"******************************************************************************
    let l:defaultIndex = (a:0 ? a:1 : -1)
    let l:confirmList = ingo#query#confirm#AutoAccelerators(copy(a:list), -1)
    let l:accelerators = map(copy(l:confirmList), 'matchstr(v:val, "&\\zs.")')
    let l:list = ingo#query#fromlist#RenderList(l:confirmList, l:defaultIndex, '%d:')

    let l:renderedQuestion = printf('Select %s via [count] or (l)etter: %s ?', a:what, join(l:list, ', '))
    if ingo#compat#strdisplaywidth(l:renderedQuestion) + 3 > &columns
	call ingo#query#Question(printf('Select %s via [count] or (l)etter:', a:what))
	for l:listItem in ingo#query#fromlist#RenderList(l:confirmList, l:defaultIndex, '%3d: ')
	    echo l:listItem
	endfor
    else
	call ingo#query#Question(l:renderedQuestion)
    endif

    if exists('g:IngoLibrary_QueryChoices') && len(g:IngoLibrary_QueryChoices) > 0
	" Headless mode: Bypass actual confirm so that no user intervention is
	" necesary.
	let l:plainChoices = map(copy(a:list), 'ingo#query#StripAccellerator(v:val)')

	" Return predefined choice.
	let l:choice = remove(g:IngoLibrary_QueryChoices, 0)
	return (type(l:choice) == type(0) ?
	\   l:choice :
	\   (l:choice == '' ?
	\       0 :
	\       index(l:plainChoices, l:choice)
	\   )
	\)
    endif

    let l:maxNum = len(a:list)
    let l:choice = ingo#query#get#Char()
    let l:count = (empty(l:choice) ? -1 : index(l:accelerators, l:choice, 0, 1)) + 1
    if l:count == 0 && l:choice =~# '^\d$'
	let l:count = str2nr(l:choice)
	if l:maxNum > 10 * l:count
	    " Need to query more numbers to be able to address all choices.
	    echon ' ' . l:count

	    let l:leadingZeroCnt = (l:choice ==# '0')
	    while l:maxNum > 10 * l:count
		let l:char = nr2char(getchar())
		if l:char ==# "\<CR>"
		    break
		elseif l:char !~# '\d'
		    redraw | echo ''
		    return -1
		endif

		echon l:char
		if l:char ==# '0' && l:count == 0
		    let l:leadingZeroCnt += 1
		    if l:leadingZeroCnt >= len(l:maxNum)
			return -1
		    endif
		else
		    let l:count = 10 * l:count + str2nr(l:char)
		    if l:leadingZeroCnt + len(l:count) >= len(l:maxNum)
			break
		    endif
		endif
	    endwhile
	endif
    endif

    if l:count < 1 || l:count > l:maxNum
	redraw | echo ''
	return -1
    endif
    return l:count - 1
endfunction

function! ingo#query#fromlist#QueryAsText( what, list, ... )
"******************************************************************************
"* PURPOSE:
"   Query for one entry from a:list; elements can be selected by accelerator key
"   or the number of the element. Supports "headless mode", i.e. bypassing the
"   actual dialog so that no user intervention is necessary (in automated
"   tests).
"* SEE ALSO:
"   ingo#query#recall#Query() provides an alternative means to query one
"   (longer) entry from a list.
"* ASSUMPTIONS / PRECONDITIONS:
"   The headless mode is activated by defining a List of choices (either
"   numerical return values of confirm(), or the choice text without the
"   shortcut key "&") in g:IngoLibrary_QueryChoices. Each invocation of this
"   function removes the first element from that List and returns it.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Description of what is queried.
"   a:list  List of elements. Accelerators can be preset by prefixing with "&".
"   a:defaultIndex  Default element (which will be chosen via <Enter>); -1 for
"		    no default.
"* RETURN VALUES:
"   Choice text without the shortcut key '&'. Empty string if the dialog was
"   aborted.
"******************************************************************************
    let l:index = call('ingo#query#fromlist#Query', [a:what, a:list] + a:000)
    return (l:index == -1 ? '' : a:list[l:index])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
