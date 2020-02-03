" ingo/regexp/length.vim: Functions to compare the length of regular expression matches.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/list/split.vim autoload script
"   - ingo/regexp/collection.vim autoload script
"   - ingo/regexp/deconstruct.vim autoload script
"   - ingo/regexp/magic.vim autoload script
"   - ingo/regexp/multi.vim autoload script
"   - ingo/regexp/split.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:AddWithLimit( accumulator, value )
    return (a:accumulator == 0x7FFFFFFF || a:value == 0x7FFFFFFF ?
    \   0x7FFFFFFF :
    \   min([a:accumulator + a:value, 0x7FFFFFFF])
    \)
endfunction
function! s:AddMinMax( accumulatorList, valueList )
    let a:accumulatorList[0] = s:AddWithLimit(a:accumulatorList[0], a:valueList[0])
    let a:accumulatorList[1] = s:AddWithLimit(a:accumulatorList[1], a:valueList[1])
    return a:accumulatorList
endfunction
function! s:OverallMinMax( minMaxList )
    let l:minLengths = map(copy(a:minMaxList), 'v:val[0]')
    let l:maxLengths = map(copy(a:minMaxList), 'v:val[1]')
    return [min(l:minLengths), max(maxLengths)]
endfunction
function! ingo#regexp#length#Project( pattern )
"******************************************************************************
"* PURPOSE:
"   Estimate the number of characters that a:pattern will match. Of course, this
"   works best if the pattern specifies a literal match or only has fixed-width
"   atoms.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression to analyze.
"* RETURN VALUES:
"   List of [minLength, maxLength]. For complex expressions or unbounded multis
"   like |/*| , assumes a minimum of 0 and a maximum of 0x7FFFFFFF.
"   Throws 'PrefixGroupsSuffix: Unmatched \(' or
"   'PrefixGroupsSuffix: Unmatched \)' if a:pattern is invalid.
"******************************************************************************
    let l:branches = ingo#regexp#split#TopLevelBranches(ingo#regexp#split#GlobalFlags(a:pattern)[-1])
    let l:minMaxBranches = map(
    \   l:branches,
    \   's:ProjectBranch(v:val)'
    \)
    return s:OverallMinMax(l:minMaxBranches)
endfunction
function! s:ProjectBranch( pattern )
    let l:splits = ingo#regexp#split#PrefixGroupsSuffix(a:pattern)
    if len(l:splits) == 1
	return s:ProjectUngroupedPattern(a:pattern)
    endif

    call add(l:splits, '')  " Add one empty branch to be able to handle the last real one in a consistent way.
    let l:minMaxes = [0, 0]
    let l:previousMinMax = [0, 0]
    while len(l:splits) > 1
	let l:prefix = remove(l:splits, 0)
	let [l:multi, l:rest] = matchlist(l:prefix, '^\(' . ingo#regexp#multi#Expr() . '\)\?\(.\{-}\)$')[1:2]
	if empty(l:multi)
	    call s:AddMinMax(l:minMaxes, l:previousMinMax)
	else
	    let l:prefix = l:rest
	    call s:AddMinMax(l:minMaxes, s:Multiply(l:previousMinMax, l:multi))
	endif
	call s:AddMinMax(l:minMaxes, s:ProjectUngroupedPattern(l:prefix))

	let l:group = remove(l:splits, 0)
	let l:previousMinMax = ingo#regexp#length#Project(l:group)
    endwhile

    return l:minMaxes
endfunction
function! s:Multiply( minMax, multi )
    let [l:minLength, l:maxLength] = a:minMax
    let [l:minMultiplier, l:maxMultiplier] = s:ProjectMulti(a:multi)

    return [l:minLength * l:minMultiplier, l:maxLength * l:maxMultiplier]
endfunction
function! s:ProjectUngroupedPattern( pattern )
    let l:patternMultis =
    \   ingo#list#split#ChunksOf(
    \       ingo#collections#SplitKeepSeparators(
    \           a:pattern,
    \           ingo#regexp#multi#Expr(),
    \           1
    \       ),
    \       2, ''
    \   )

    let l:minMaxMultis = map(
    \   filter(
    \       l:patternMultis,
    \       'v:val !=# ["", ""]'
    \   ),
    \   's:ProjectMultis(v:val[0], v:val[1])'
    \)

    return ingo#collections#Reduce(l:minMaxMultis, function('s:AddMinMax'), [0, 0])
endfunction
function! s:ProjectMultis( pattern, multi )
    let l:minMaxes = [0, 0]
    call s:AddMinMax(l:minMaxes, s:ProjectUngroupedSinglePattern(a:pattern))
    call s:AddMinMax(l:minMaxes, [-1, -1])  " The tally for the atom before the multi is contained in the multi, so we need to subtract one. Simply cutting it off would be more difficult, because it could be an escaped special character or a collection.
    call s:AddMinMax(l:minMaxes, s:ProjectMulti(a:multi))
    return l:minMaxes
endfunction
function! s:ProjectUngroupedSinglePattern( pattern )
    let l:patternWithoutCollections = s:RemoveCollections(a:pattern)
    let l:literalText = ingo#regexp#deconstruct#ToQuasiLiteral(l:patternWithoutCollections)
    let l:literalTextLength = ingo#compat#strchars(l:literalText)
    return [l:literalTextLength, l:literalTextLength]
endfunction
function! s:RemoveCollections( pattern )
    return substitute(a:pattern, ingo#regexp#collection#Expr(), 'x', 'g')
endfunction
function! s:ProjectMulti( multi )
    if empty(a:multi)
	return [1, 1]
    elseif a:multi ==# '*'
	return [0, 0x7FFFFFFF]
    elseif a:multi ==# '\+'
	return [1, 0x7FFFFFFF]
    elseif a:multi ==# '\?'
	return [0, 1]
    elseif a:multi =~# '^\\{'
	let l:range = matchstr(a:multi, '^\\{-\?\zs[[:digit:],]*\ze}$')
	if l:range ==# a:multi | throw 'ASSERT: Invalid multi syntax' | endif
	if l:range =~# ','
	    let l:rangeNumbers = split(l:range, ',', 1)
	    return [
	    \   empty(l:rangeNumbers[0]) ? 0 : str2nr(l:rangeNumbers[0]),
	    \   empty(l:rangeNumbers[1]) ? 0x7FFFFFFF : str2nr(l:rangeNumbers[1])
	    \]
	else
	    return (empty(l:range) ?
	    \   [0, 0x7FFFFFFF] :
	    \   [str2nr(l:range), str2nr(l:range)]
	    \)
	endif
    elseif a:multi ==# '\@>'
	return [1, 1]
    elseif a:multi =~# '^\\@'
	return [0, 0]
    else
	throw 'ASSERT: Unhandled multi: ' . string(a:multi)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
