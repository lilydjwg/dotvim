" ingo/list/lcs.vim: Functions to find longest common substring(s).
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/str/split.vim autoload script
"
" Copyright: (C) 2017-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#list#lcs#FindLongestCommon( strings, ... )
"******************************************************************************
"* PURPOSE:
"   Find the (first) longest common substring that occurs in each of a:strings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strings   List of strings.
"   a:minimumLength Minimum substring length; default 1.
"   a:isIgnoreCase  Flag whether the search is done without considering case
"                   (default: 0).
"* RETURN VALUES:
"   Longest string that occurs in all of a:strings, or empty string if there's
"   no commonality at all.
"******************************************************************************
    let l:minimumLength = (a:0 ? a:1 : 1)
    let l:ignoreCaseAtom = (a:0 >= 2 && a:2 ? '\c' : '')
    let l:pos = 0
    let l:maxMatchLen = 0
    let l:maxMatch = ''

    while 1
	let [l:match, l:startPos, l:endPos] = ingo#compat#matchstrpos(
	\   join(a:strings + [''], "\n"),
	\   printf(l:ignoreCaseAtom . '^[^\n]\{-}\zs\([^\n]\{%d,}\)\ze[^\n]\{-}\n\%([^\n]\{-}\1[^\n]*\n\)\{%d}$', l:minimumLength, len(a:strings) - 1),
	\   l:pos
	\)
	if l:startPos == -1
	    break
	endif
	let l:pos = l:endPos
"****D echomsg '****' l:match
	let l:matchLen = ingo#compat#strchars(l:match)
	if l:matchLen > l:maxMatchLen
	    let l:maxMatch = l:match
	    let l:maxMatchLen = l:matchLen
	endif
    endwhile

    return l:maxMatch
endfunction

function! ingo#list#lcs#FindAllCommon( strings, ... )
"******************************************************************************
"* PURPOSE:
"   Find all common substrings that occur in each of a:strings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strings                   List of strings.
"   a:minimumCommonLength       Minimum substring length; default 1.
"   a:minimumDifferingLength    Minimum length or [minimumPrefixDifferingLength,
"                               minimumSuffixDifferingLength]; default 0.
"   a:isIgnoreCase              Flag whether the search is done without
"                               considering case (default: 0).
"* RETURN VALUES:
"   [distinctLists, commons], as in:
"   [
"	[prefix1, prefix2, ...], [middle1, middle2, ...], ..., [suffix1, suffix2, ...],
"	[commonBetweenPrefixAndMiddle, ..., commonBetweenMiddleAndSuffix]
"   ]
"   The commons List always contains one element less than distinctLists; its
"   elements are meant to go between those of the first List.
"   If all strings start or end with a common substring, [prefix1, prefix2, ...]
"   / [suffix1, suffix2, ...] is the empty List [].
"******************************************************************************
    let l:minimumCommonLength = (a:0 ? a:1 : 1)
    let [l:minimumPrefixDifferingLength, l:minimumSuffixDifferingLength] = (a:0 >= 2 ?
    \   (type(a:2) == type([]) ?
    \       a:2 :
    \       [a:2, a:2]
    \   ) :
    \   [0, 0]
    \)
    let l:isIgnoreCase = (a:0 >= 3 ? a:3 : 0)


    let l:common = ingo#list#lcs#FindLongestCommon(a:strings, l:minimumCommonLength, l:isIgnoreCase)
    if empty(l:common)
	return [[a:strings], []]
    endif

    let [l:differingCnt, l:prefixes, l:suffixes] = s:Split(a:strings, l:common, l:isIgnoreCase)

    let l:isPrefixTooShort = s:IsTooShort(l:prefixes, l:minimumPrefixDifferingLength)
    let l:isSuffixTooShort = s:IsTooShort(l:suffixes, l:minimumSuffixDifferingLength)
    if l:isPrefixTooShort
	if l:isSuffixTooShort
	    " No more recursion. Join back prefixes, common, and suffixes. Oh
	    " wait, we can just return the original List.
	    return [[a:strings], []]

	    "let [l:prefixDiffering, l:prefixCommon] = [[map(range(l:differingCnt), 'get(l:prefixes, v:val, "") . l:common . get(l:suffixes, v:val, "")')], []]
	    "let l:common = ''
	    "let [l:suffixDiffering, l:suffixCommon] = [[], []]
	else
	    " Recurse into the suffixes, then join its first distincts with the
	    " prefixes and common.
	    let [l:suffixDiffering, l:suffixCommon] = ingo#list#lcs#FindAllCommon(l:suffixes, l:minimumCommonLength, [0, l:minimumSuffixDifferingLength], l:isIgnoreCase) " Minimum prefix length doesn't apply here, as we're joining it.

	    let [l:prefixDiffering, l:prefixCommon] = [[map(range(l:differingCnt), 'get(l:prefixes, v:val, "") . l:common . get(get(l:suffixDiffering, 0, []), v:val, "")')], []]
	    let l:common = ''
	    call remove(l:suffixDiffering, 0)
	endif
    elseif l:isSuffixTooShort
	" Recurse into the prefixes, then join its last distincts with common
	" and the suffixes.
	let [l:prefixDiffering, l:prefixCommon] = ingo#list#lcs#FindAllCommon(l:prefixes, l:minimumCommonLength, [l:minimumPrefixDifferingLength, 0], l:isIgnoreCase) " Minimum suffix length doesn't apply here, as we're joining it.
	let [l:suffixDiffering, l:suffixCommon] = [[map(range(l:differingCnt), 'get(l:prefixDiffering[-1], v:val, "") . l:common . get(l:suffixes, v:val, "")')], []]
	let l:common = ''
	call remove(l:prefixDiffering, -1)
    else
	" Recurse into both prefixes and suffixes.
	let [l:prefixDiffering, l:prefixCommon] = ingo#list#lcs#FindAllCommon(l:prefixes, l:minimumCommonLength, [l:minimumPrefixDifferingLength, l:minimumSuffixDifferingLength], l:isIgnoreCase)
	let [l:suffixDiffering, l:suffixCommon] = ingo#list#lcs#FindAllCommon(l:suffixes, l:minimumCommonLength, [l:minimumPrefixDifferingLength, l:minimumSuffixDifferingLength], l:isIgnoreCase)
    endif

    return [
    \   l:prefixDiffering + l:suffixDiffering,
    \   filter(l:prefixCommon + [l:common] + l:suffixCommon, '! empty(v:val)')
    \]
endfunction
function! s:IsTooShort( list, minimumLength )
    return a:minimumLength > 0 &&
    \   min(map(copy(a:list), 'ingo#compat#strchars(v:val)')) < a:minimumLength &&
    \   ! ingo#list#IsEmpty(a:list)
endfunction
function! s:Split( strings, common, isIgnoreCase )
    let l:prefixes = []
    let l:suffixes = []

    for l:string in a:strings
	if a:isIgnoreCase
	    let [l:prefix, l:ignoredMatchedText, l:suffix] = ingo#str#split#MatchFirst(l:string, '\V\c' . escape(a:common, '\'))
	else
	    let [l:prefix, l:suffix] = ingo#str#split#StrFirst(l:string, a:common)
	endif
	call add(l:prefixes, l:prefix)
	call add(l:suffixes, l:suffix)
    endfor

    return [len(l:prefixes), s:Shorten(l:prefixes), s:Shorten(l:suffixes)]
endfunction
function! s:Shorten( list )
    return (ingo#list#IsEmpty(a:list) ?
    \   [] :
    \   a:list
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
