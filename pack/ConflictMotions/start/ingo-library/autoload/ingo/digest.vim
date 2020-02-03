" ingo/digest.vim: Functions to create short digests from larger collections of text.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/dict/count.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.031.002	31-May-2017	FIX: Potentially invalid indexing of
"				l:otherResult[l:i] in s:GetUnjoinedResult(). Use
"				get() for inner List access, too.
"   1.030.001	24-May-2017	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#digest#Get( items, itemSplitPattern, ... )
"******************************************************************************
"* PURPOSE:
"   Split Strings in a:items into parts according to a:itemSplitPattern, and
"   keep those (and surrounding separators) that occur in all / a:percentage.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:items             List of input Strings.
"   a:itemSplitPattern  Regular expression that identifies the separators of
"			each item.
"   a:percentage        Optional value between 1 and 100 that specifies the
"			percentage of the items in which a part has to occur in
"			order to be kept in the digest. Default 100, i.e. a part
"			has to occur in all items.
"* RETURN VALUES:
"   List of non-consecutive parts that occur in all / a:percentage of items.
"   Consecutive parts are re-joined.
"******************************************************************************
    let l:separation = map(
    \   copy(a:items),
    \   'ingo#collections#SeparateItemsAndSeparators(v:val, a:itemSplitPattern, 1)'
    \)
    let l:itemsParts      = map(copy(l:separation), 'v:val[0]')
    let l:itemsSeparators = map(copy(l:separation), 'v:val[1]')
"****D echomsg '****' string(l:itemsParts) '+' string(l:itemsSeparators)
    let l:counts = {}
    for l:items in l:itemsParts
	call ingo#dict#count#Items(l:counts, ingo#collections#Unique(l:items))
    endfor

    let l:accepted = filter(
    \   copy(l:counts),
    \   'v:val' . (a:0 ?
    \       printf(' * 100 / %d >= %d', len(a:items), a:1) :
    \       ' == ' . len(a:items)
    \   )
    \)
"****D echomsg '****' string(l:counts) '->' string(l:accepted)
    let l:evaluation = map(l:separation, 's:Evaluate(v:val[0], v:val[1], l:accepted)')

    " When a percentage is given, select the longest parts, to consider that not
    " every item contains all parts. Without a percentage, all parts should be
    " contained, so the shortest parts is chosen.
    let l:filteredItems = s:FilterItems((a:0 ? 'max' : 'min'), l:evaluation)
"****D echomsg '****' string(l:filteredItems)
    let l:unjoinedResult = s:GetUnjoinedResult(l:filteredItems)
"****D echomsg '****' string(l:unjoinedResult)
    return s:UnjoinResult(l:unjoinedResult)
endfunction
function! s:Evaluate( parts, separators, accepted )
    let l:result = [0]
    let l:lastAcceptedIndex = -2
    for l:i in range(len(a:parts))
	let l:part = a:parts[l:i]
	if has_key(a:accepted, l:part)
	    if l:lastAcceptedIndex + 1 == l:i
		call add(l:result[-1], l:part)
		call add(l:result[-1], get(a:separators, l:i, ''))
	    else
		call add(l:result, [(l:i > 0 ? get(a:separators, l:i - 1, '') : ''), l:part, get(a:separators, l:i, '')])
	    endif
	    let l:lastAcceptedIndex = l:i
	    let l:result[0] += 1
	endif
    endfor
    return l:result
endfunction
function! s:FilterItems( Comparer, evaluation )
    let l:partsNum = call(a:Comparer, [map(copy(a:evaluation), 'v:val[0]')])
    return
    \   map(
    \       filter(
    \           copy(a:evaluation),
    \           'v:val[0] == l:partsNum'
    \       ),
    \       'v:val[1:]'
    \   )
endfunction
function! s:GetUnjoinedResult( filteredItems )
    let l:unjoinedResult = a:filteredItems[0]
    for l:i in range(len(l:unjoinedResult))
	let l:j = 0
	while l:j < len(l:unjoinedResult[l:i])
	    for l:otherResult in a:filteredItems[1:]
		if type(l:unjoinedResult[l:i][l:j]) != type([]) &&
		\   get(get(l:otherResult, l:i, []), l:j, '') !=# l:unjoinedResult[l:i][l:j]
		    let l:unjoinedResult[l:i][l:j] = [] " Discontinuation marker: split here later.
		endif
	    endfor
	    let l:j += 2    " Only check the separators on positions 0, 2, 4, ...
	endwhile
    endfor
    return l:unjoinedResult
endfunction
function! s:UnjoinResult( unjoinedResult )
    let l:result = ['']
    for l:resultPart in a:unjoinedResult
	while ! empty(l:resultPart)
	    if type(l:resultPart[0]) == type([]) && l:resultPart[0] == []
		call remove(l:resultPart, 0)
		call add(l:result, '')
	    else
		let l:result[-1] .= remove(l:resultPart, 0)
	    endif
	endwhile

	call add(l:result, '')
    endfor

    return filter(l:result, '! empty(v:val)')
endfunction

function! ingo#digest#BufferList( bufferList, ... )
"******************************************************************************
"* PURPOSE:
"   Determine common elements from the passed a:bufferList.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:bufferList	List of buffer numbers (or names).
"   a:percentage        Optional value between 1 and 100 that specifies the
"			percentage of the items in which a part has to occur in
"			order to be kept in the digest. Default 100, i.e. a part
"			has to occur in all items.
"* RETURN VALUES:
"   List of non-consecutive parts that occur in all / a:percentage of buffer
"   names. Consecutive parts are re-joined.
"******************************************************************************
    " Commonality in path and file name (without extensions)?
    let l:digest = call('ingo#digest#Get', [map(copy(a:bufferList), 'fnamemodify(bufname(v:val), ":p:r")'), '\A\+'] + a:000)
    if empty(l:digest)
	" Commonality in file extensions?
	let l:digest = call('ingo#digest#Get', [map(copy(a:bufferList), 'fnamemodify(bufname(v:val), ":e")'), '\A\+'] + a:000)
    endif
    if empty(l:digest)
	" Commonality in CamelParts?
	let l:digest = call('ingo#digest#Get', [map(copy(a:bufferList), 'fnamemodify(bufname(v:val), ":p")'), '\l\zs\ze\u'] + a:000)
    endif

    return l:digest
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
