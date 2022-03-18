" ingo/window/locate.vim: Functions to locate a window.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"
" Copyright: (C) 2016-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	25-Nov-2016	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:Match( winVarName, Predicate, winNr, ... )
    if a:0 >= 2 && a:winNr == a:2
	return 0
    endif
    let l:tabNr = (a:0 ? a:1 : tabpagenr())
    let l:value = (a:winVarName ==# 'bufnr' ?
    \   get(tabpagebuflist(l:tabNr), a:winNr - 1, '') :
    \   gettabwinvar(l:tabNr, a:winNr, a:winVarName)
    \)
    return !! ingo#actions#EvaluateWithValOrFunc(a:Predicate, l:value)
endfunction

function! s:CheckTabPageNearest( tabNr, winVarName, Predicate, ... )
    let l:skipWinNr = (a:0 ? a:1 : 0)
    let [l:currentWinNr, l:previousWinNr, l:lastWinNr] = [tabpagewinnr(a:tabNr), tabpagewinnr(a:tabNr, '#'), tabpagewinnr(a:tabNr, '$')]
    if s:Match(a:winVarName, a:Predicate, l:currentWinNr, a:tabNr, l:skipWinNr)
	return [a:tabNr, l:currentWinNr]
    elseif s:Match(a:winVarName, a:Predicate, l:previousWinNr, a:tabNr, l:skipWinNr)
	return [a:tabNr, l:previousWinNr]
    endif

    let l:offset = 1
    while l:currentWinNr - l:offset > 0 || l:currentWinNr + l:offset <= l:lastWinNr
	if s:Match(a:winVarName, a:Predicate, l:currentWinNr - l:offset, a:tabNr, l:skipWinNr)
	    return [a:tabNr, l:currentWinNr - l:offset]
	elseif s:Match(a:winVarName, a:Predicate, l:currentWinNr + l:offset, a:tabNr, l:skipWinNr)
	    return [a:tabNr, l:currentWinNr + l:offset]
	endif
	let l:offset += 1
    endwhile
    return [0, 0]
endfunction

function! ingo#window#locate#NearestByPredicate( isSearchOtherTabPages, winVarName, Predicate )
"******************************************************************************
"* PURPOSE:
"   Locate the window closest to the current one where the window variable
"   a:winVarName makes a:Predicate (passed in as argument or v:val) true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:winVarName            Name of the window-local variable, like in
"			    |gettabwinvar()|. Also supports a special "bufnr"
"			    variable that resolves to |bufnr()|.
"   a:Predicate             Either a Funcref or an expression to be eval()ed.
"			    Gets the value of a:winVarName passed, should return
"			    a boolean value.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the found window is on a
"	different tab page
"   [0, winnr] if the window is on the current tab page
"   [0, 0] if a:Predicate did not yield true in any other window
"******************************************************************************
    let l:lastWinNr = winnr('#')
    if l:lastWinNr != 0 && s:Match(a:winVarName, a:Predicate, l:lastWinNr)
	return [tabpagenr(), l:lastWinNr]
    endif

    let l:result = s:CheckTabPageNearest(tabpagenr(), a:winVarName, a:Predicate, winnr())
    if l:result != [0, 0] || ! a:isSearchOtherTabPages
	return l:result
    endif


    let [l:currentTabPageNr, l:lastTabPageNr] = [tabpagenr(), tabpagenr('$')]
    let l:offset = 1
    while l:currentTabPageNr - l:offset > 0 || l:currentTabPageNr + l:offset <= l:lastTabPageNr
	let l:result = s:CheckTabPageNearest(l:currentTabPageNr - l:offset, a:winVarName, a:Predicate)
	if l:result != [0, 0] | return l:result | endif

	let l:result = s:CheckTabPageNearest(l:currentTabPageNr + l:offset, a:winVarName, a:Predicate)
	if l:result != [0, 0] | return l:result | endif

	let l:offset += 1
    endwhile

    return [0, 0]
endfunction

function! ingo#window#locate#FirstByPredicate( isSearchOtherTabPages, winVarName, Predicate )
"******************************************************************************
"* PURPOSE:
"   Locate the first window (in this tab page, or with a:isSearchOtherTabPages
"   in other tabs) where the window variable a:winVarName makes a:Predicate
"   (passed in as argument or v:val) true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:winVarName            Name of the window-local variable, like in
"			    |gettabwinvar()|. Also supports a special "bufnr"
"			    variable that resolves to |bufnr()|.
"   a:Predicate             Either a Funcref or an expression to be eval()ed.
"			    Gets the value of a:winVarName passed, should return
"			    a boolean value.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the found window is on a
"	different tab page
"   [0, winnr] if the window is on the current tab page
"   [0, 0] if a:Predicate did not yield true in any other window
"******************************************************************************
    for l:winNr in range(1, winnr('$'))
	if s:Match(a:winVarName, a:Predicate, l:winNr)
	    return [0, l:winNr]
	endif
    endfor
    if ! a:isSearchOtherTabPages
	return [0, 0]
    endif

    for l:tabPageNr in filter(range(1, tabpagenr('$')), 'v:val != ' . tabpagenr())
	let l:lastWinNr = tabpagewinnr(l:tabPageNr, '$')
	for l:winNr in range(1, l:lastWinNr)
	    if s:Match(a:winVarName, a:Predicate, l:winNr, l:tabPageNr)
		return [l:tabPageNr, l:winNr]
	    endif
	endfor
    endfor

    return [0, 0]
endfunction

function! ingo#window#locate#ByPredicate( strategy, isSearchOtherTabPages, winVarName, Predicate )
"******************************************************************************
"* PURPOSE:
"   Locate a window (in this tab page, or with a:isSearchOtherTabPages in other
"   tabs), with a:strategy to determine precedences, where the window variable
"   a:winVarName makes a:Predicate (passed in as argument or v:val) true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strategy              One of "first" or "nearest".
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:winVarName            Name of the window-local variable, like in
"			    |gettabwinvar()|. Also supports a special "bufnr"
"			    variable that resolves to |bufnr()|.
"   a:Predicate             Either a Funcref or an expression to be eval()ed.
"			    Gets the value of a:winVarName passed, should return
"			    a boolean value.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the found window is on a
"	different tab page
"   [0, winnr] if the window is on the current tab page
"   [0, 0] if a:Predicate did not yield true in any other window
"******************************************************************************
    if a:strategy ==# 'first'
	return ingo#window#locate#FirstByPredicate(a:isSearchOtherTabPages, a:winVarName, a:Predicate)
    elseif a:strategy ==# 'nearest'
	return ingo#window#locate#NearestByPredicate(a:isSearchOtherTabPages, a:winVarName, a:Predicate)
    else
	throw 'ASSERT: Unknown strategy ' . string(a:strategy)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vism: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
