" ingo/collections/find.vim: Functions for finding values in collections.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#collections#find#Extremes( expr1, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Expr2 on each item of a:expr1 into a number, and return those
"   element(s) that have the lowest and highest numbers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr1 List or Dictionary to be searched.
"   a:Expr  Expression to be evaluated; v:val has the value of the current item.
"	    v:key is the key (Dictionary) / index (List) of the current item.
"	    If a:Expr is a Funcref it is called with the key / index and the
"	    value of the current item. (Like |map()|.)
"	    Should return a number.
"* RETURN VALUES:
"   [[lowestItem1, ...], [highestItem1, ...]
"******************************************************************************
    let l:evaluation = map(copy(a:expr1), a:Expr2)
    let [l:min, l:max] = [min(l:evaluation), max(l:evaluation)]

    if type(a:expr1) == type([])
	let [l:minList, l:maxList] = [[], []]
	let l:idx = 0
	while l:idx < len(a:expr1)
	    if l:evaluation[l:idx] == l:min
		call add(l:minList, a:expr1[l:idx])
	    endif
	    if l:evaluation[l:idx] == l:max
		call add(l:maxList, a:expr1[l:idx])
	    endif
	    let l:idx += 1
	endwhile
	return [l:minList, l:maxList]
    elseif type(a:expr1) == type({})
	let [l:minDict, l:maxDict] = [{}, {}]
	for l:key in keys(a:expr1)
	    if l:evaluation[l:key] == l:min
		let l:minDict[l:key] = a:expr1[l:key]
	    endif
	    if l:evaluation[l:key] == l:max
		let l:maxDict[l:key] = a:expr1[l:key]
	    endif
	endfor
	return [l:minDict, l:maxDict]
    else
	throw 'ASSERT: a:expr1 must be either List or Dictionary'
    endif
endfunction
function! ingo#collections#find#Lowest( expr1, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Expr2 on each item of a:expr1 into a number, and return those
"   element(s) that have the lowest numbers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr1 List or Dictionary to be searched.
"   a:Expr  Expression to be evaluated; v:val has the value of the current item.
"	    v:key is the key (Dictionary) / index (List) of the current item.
"	    If a:Expr is a Funcref it is called with the key / index and the
"	    value of the current item. (Like |map()|.)
"	    Should return a number.
"* RETURN VALUES:
"   [lowestItem1, ...]
"******************************************************************************
    return ingo#collections#find#Extremes(a:expr1, a:Expr2)[0]
endfunction
function! ingo#collections#find#Highest( expr1, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Expr2 on each item of a:expr1 into a number, and return those
"   element(s) that have the lowest numbers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr1 List or Dictionary to be searched.
"   a:Expr  Expression to be evaluated; v:val has the value of the current item.
"	    v:key is the key (Dictionary) / index (List) of the current item.
"	    If a:Expr is a Funcref it is called with the key / index and the
"	    value of the current item. (Like |map()|.)
"	    Should return a number.
"* RETURN VALUES:
"   [highestItem1, ...]
"******************************************************************************
    return ingo#collections#find#Extremes(a:expr1, a:Expr2)[1]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
