" ingo/folds/containment.vim: Functions for determining how folds are contained in each other.
"
" DEPENDENCIES:
"   - ingo/folds.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:GetRawStructure( startLnum, endLnum, endFoldLevel )
"******************************************************************************
"* PURPOSE:
"   Get the ranges of folds for each fold level in the [a:startLnum, a:endLnum]
"   range, starting with the current level, up to a:endFoldLevel.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Unless the current fold state exactly corresponds to 'foldlevel', folds may
"   open / close.
"* INPUTS:
"   a:startLnum First line of the range.
"   a:endLnum   Last line of the range.
"   a:endFoldLevel  Maximum fold level for which the structure is determined.
"                   The function may stop earlier if there are not so many
"                   nested folds.
"* RETURN VALUES:
"   List (starting with the current 'foldlevel') of levels containing Lists of
"   fold ranges.
"******************************************************************************
    let l:save_foldlevel = &l:foldlevel

    let l:result = []
    while &l:foldlevel < a:endFoldLevel
	let l:foldRanges = ingo#folds#GetClosedFolds(a:startLnum, a:endLnum)
	if empty(l:foldRanges)
	    break
	endif

	call add(l:result, l:foldRanges)
	let &l:foldlevel += 1
    endwhile

    let &l:foldlevel = l:save_foldlevel
    return l:result
endfunction
function! s:MakeFoldStructureObject( foldRange )
    return {'range': a:foldRange, 'folds': []}
endfunction
function! s:Insert( results, foldRange )
    for l:result in a:results
	if s:IsInside(l:result.range, a:foldRange)
	    if ! s:Insert(l:result.folds, a:foldRange)
		call add(l:result.folds, s:MakeFoldStructureObject(a:foldRange))
	    endif
	    return 1
	endif
    endfor
    return 0
endfunction
function! s:IsInside( resultRange, foldRange )
    return a:foldRange[0] >= a:resultRange[0] && a:foldRange[1] <= a:resultRange[1]
endfunction
function! ingo#folds#containment#GetStructure( startLnum, endLnum, ... )
"******************************************************************************
"* PURPOSE:
"   Create a nested structure of fold information, similar to what is visualized
"   by the fold column. Each element contains the folded line range in the range
"   attribute, and a List of contained sub-folds in the folds attribute.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Unless the current fold state exactly corresponds to 'foldlevel', folds may
"   open / close.
"* INPUTS:
"   a:startLnum First line of the range.
"   a:endLnum   Last line of the range.
"   a:endFoldLevel  Optional maximum fold level for which the structure is
"                   determined. The function may stop earlier if there are not
"                   so many nested folds.
"* RETURN VALUES:
"   Nested List of [{'range': [2, 34], 'folds': [{...}, ...]}]
"******************************************************************************
    let l:endFoldLevel = (a:0 ? a:1 : 999)

    let l:rawStructure = s:GetRawStructure(a:startLnum, a:endLnum, l:endFoldLevel)
    if empty(l:rawStructure)
	return []
    endif

    let l:results = map(l:rawStructure[0], 's:MakeFoldStructureObject(v:val)')
    for l:levelStructure in l:rawStructure[1:]
	for l:levelFoldRange in l:levelStructure
	    call s:Insert(l:results, l:levelFoldRange)
	endfor
    endfor

    return l:results
endfunction

function! s:CountOneFoldLevel( structure )
    return map(a:structure, 'empty(v:val.folds) ? (v:val.range[1] - v:val.range[0] + 1) : s:CountOneFoldLevel(v:val.folds)')
endfunction
function! ingo#folds#containment#GetContainedFoldCounts( ...  )
"******************************************************************************
"* PURPOSE:
"   Create a nested structure that represents the nesting of folds in the passed
"   range. Each nested List represents a contained fold; numbers represent the
"   number of lines in leaf-level folds.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Unless the current fold state exactly corresponds to 'foldlevel', folds may
"   open / close.
"* INPUTS:
"   a:startLnum First line of the range.
"   a:endLnum   Last line of the range.
"   a:endFoldLevel  Optional maximum fold level for which the structure is
"                   determined. The function may stop earlier if there are not
"                   so many nested folds.
"* RETURN VALUES:
"   List of Lists of numbers of lines that are folded but not further folded.
"******************************************************************************
    let l:structure = call('ingo#folds#containment#GetStructure', a:000)
    return s:CountOneFoldLevel(l:structure)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
