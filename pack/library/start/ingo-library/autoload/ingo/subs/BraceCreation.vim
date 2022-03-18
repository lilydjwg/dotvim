" ingo/subs/BraceCreation.vim: Condense multiple strings into a Brace Expression like in Bash.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/list/lcs.vim autoload script
"   - ingo/list/sequence.vim autoload script
"
" Copyright: (C) 2017-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#subs#BraceCreation#FromSplitString( text, ... )
"******************************************************************************
"* PURPOSE:
"   Split a:text into WORDs (or on a:separatorPattern), extract common
"   substrings, and turn these into a (shorter) Brace Expression, like in Bash.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Source text with multiple strings.
"   a:separatorPattern  Regular expression to separate the source text into
"			strings. Defaults to whitespace (also when empty string
"			is passed).
"   a:options           Additional options; see
"			ingo#subs#BraceCreation#FromList().
"* RETURN VALUES:
"   Brace Expression. Returns braced and comma-separated original items if no
"   common substrings could be extracted.
"******************************************************************************
    let l:separatorPattern = (a:0 && ! empty(a:1) ? a:1 : '\_s\+')

    let l:strings = split(a:text, l:separatorPattern)
    if len(l:strings) <= 1
	throw 'Only one string'
    endif
    return ingo#subs#BraceCreation#FromList(l:strings, (a:0 >= 2 ? a:2 : {}))
endfunction
function! ingo#subs#BraceCreation#FromList( list, ... )
"******************************************************************************
"* PURPOSE:
"   Extract common substrings in a:list, and turn these into a (shorter) Brace
"   Expression, like in Bash.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      List of strings.
"   a:options.returnValueOnFailure
"		Return value if there are no common substrings (or in strict
"		mode the common substrings are not a prefix or suffix).
"   a:options.strict
"		Flag whether it must be possible to mechanically expand the
"		result back into the original strings. This means that
"		opportunities to extract multiple substrings are not taken.
"   a:options.short
"		Flag to enable all optimizations, i.e.
"		optionalElementInSquareBraces and uniqueElements and
"		isIgnoreCase.
"   a:options.optionalElementInSquareBraces
"		Flag whether a single optional element is denoted as [elem]
"		instead of {elem,} (or {,elem}, or even {,,elem,}; i.e. the
"		bidirectional equivalence is lost, but the notation is more
"		readable.
"   a:options.uniqueElements
"		Flag whether duplicate elements are removed, so that only unique
"		strings are contained in there.
"   a:options.minimumCommonLength       Minimum substring length; default 1.
"   a:options.minimumDifferingLength    Minimum length; default 0.
"   a:options.isIgnoreCase              Flag whether the search is done without
"                                       considering case (default: 0).
"* RETURN VALUES:
"   Brace Expression. Returns braced and comma-separated original items if no
"   common substrings could be extracted (or a:options.returnValueOnFailure).
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    if has_key(l:options, 'short')
	if ! has_key(l:options, 'optionalElementInSquareBraces')    | let l:options.optionalElementInSquareBraces = 1 | endif
	if ! has_key(l:options, 'uniqueElements')                   | let l:options.uniqueElements = 1 | endif
	if ! has_key(l:options, 'isIgnoreCase')                     | let l:options.isIgnoreCase = 1 | endif
    endif

    let [l:distinctLists, l:commons] = ingo#list#lcs#FindAllCommon(a:list, get(l:options, 'minimumCommonLength', 1), get(l:options, 'minimumDifferingLength', 0), get(l:options, 'isIgnoreCase', 0))
    let l:isFailure = empty(l:commons)

    if ! l:isFailure && get(l:options, 'strict', 0)
	let [l:isFailure, l:distinctLists, l:commons] = s:ToStrict(a:list, l:distinctLists, l:commons)
    endif

    if l:isFailure && has_key(l:options, 'returnValueOnFailure')
	return l:options.returnValueOnFailure
    endif

    return s:Join(l:distinctLists, l:commons, (a:0 ? a:1 : {}))
endfunction
function! s:ToStrict( list, distinctLists, commons )
    let l:isCommonPrefix = empty(a:distinctLists[0])
    let l:isCommonSuffix = empty(a:distinctLists[-1])

    if ! l:isCommonPrefix && ! l:isCommonSuffix
	" Join the original strings.
	return [1, [a:list], []]
    elseif len(a:commons) > (l:isCommonPrefix && l:isCommonSuffix ? 2 : 1)
	if l:isCommonPrefix && l:isCommonSuffix
	    " Use first and last common, combine inner.
	    return [0, [[]] + s:Recombine(a:distinctLists[1:-2], a:commons[1:-2]) + [[]], [a:commons[0], a:commons[-1]]]
	elseif l:isCommonPrefix
	    " Use first common, combine rest.
	    return [0, [[]] + s:Recombine(a:distinctLists[1:], a:commons[1:]), [a:commons[0]]]
	elseif l:isCommonSuffix
	    " Use last common, combine rest.
	    return [0, s:Recombine(a:distinctLists[0: -2], a:commons[0: -2]) + [[]], [a:commons[-1]]]
	endif
    endif
    return [0, a:distinctLists, a:commons]
endfunction
function! s:Recombine( distinctLists, commons )
    let l:realDistincts = filter(copy(a:distinctLists), '! empty(v:val)')
    let l:distinctNum = len(l:realDistincts[0])
    let l:distinctAndCommonsIntermingled = ingo#list#Join(l:realDistincts, map(copy(a:commons), 'repeat([v:val], l:distinctNum)'))
    let l:indexedElementsTogether = call('ingo#list#Zip', l:distinctAndCommonsIntermingled)
    let l:joinedIndividualElements = map(l:indexedElementsTogether, 'join(v:val, "")')
    return [l:joinedIndividualElements]
endfunction
function! s:Join( distinctLists, commons, options )
    let l:result = []
    while ! empty(a:distinctLists) || ! empty(a:commons)
	if ! empty(a:distinctLists)
	    let l:distinctList = remove(a:distinctLists, 0)

	    if get(a:options, 'uniqueElements', 0)
		let l:distinctList = ingo#collections#UniqueStable(l:distinctList)
	    endif

	    call add(l:result, s:Create(a:options, l:distinctList, 1)[0])
	endif

	if ! empty(a:commons)
	    call add(l:result, remove(a:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction
function! s:Create( options, distinctList, isWrap )
    if empty(a:distinctList)
	return ['', 0]
    endif

    let [l:sequenceLen, l:stride] = ingo#list#sequence#FindNumerical(a:distinctList)
    if l:sequenceLen <= 2 || ! ingo#list#pattern#AllItemsMatch(a:distinctList[0 : l:sequenceLen - 1], '^\d\+$')
	let [l:sequenceLen, l:stride] = ingo#list#sequence#FindCharacter(a:distinctList)
    endif
    if l:sequenceLen > 2
	let l:result = a:distinctList[0] . '..' . a:distinctList[l:sequenceLen - 1] .
	\   (ingo#compat#abs(l:stride) == 1 ? '' : '..' . l:stride)

	if l:sequenceLen < len(a:distinctList)
	    " Search for further sequences in the surplus elements. If this is a
	    " sequence, we have to enclose it in {...}. A normal brace list can
	    " just be appended.
	    let [l:surplusResult, l:isSurplusSequence] = s:Create(a:options, a:distinctList[l:sequenceLen :], 0)
	    let l:result = s:Brace(l:result) . ',' . s:Brace(l:surplusResult, l:isSurplusSequence)
	endif

	return [s:Brace(l:result), a:isWrap]
    else
	if get(a:options, 'optionalElementInSquareBraces', 0)
	    let l:nonEmptyList = filter(copy(a:distinctList), '! empty(v:val)')
	    if len(l:nonEmptyList) == 1
		return [s:Wrap('[]', l:nonEmptyList[0]), 0]
	    endif
	endif

	return [s:Brace(join(map(a:distinctList, 's:Escape(v:val)'), ','), a:isWrap), 0]
    endif
endfunction
function! s:Wrap( wrap, string, ... )
    return (! a:0 || a:0 && a:1 ? a:wrap[0] . a:string . a:wrap[1] : a:string)
endfunction
function! s:Brace( string, ... )
    return call('s:Wrap', ['{}', a:string] + a:000)
endfunction
function! s:Escape( braceItem )
    return escape(a:braceItem, '{},')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
