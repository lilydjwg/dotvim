" ingo/str/split.vim: Functions for splitting strings.
"
" DEPENDENCIES:
"   - ingo/str.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#str#split#StrFirst( expr, str )
"******************************************************************************
"* PURPOSE:
"   Split a:expr into the text before and after the first occurrence of a:str.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be split.
"   a:str   The literal text to split on.
"* RETURN VALUES:
"   Tuple of [beforeStr, afterStr].
"   When there's no occurrence of a:str, the returned tuple is [a:expr, ''].
"******************************************************************************
    let l:startIdx = stridx(a:expr, a:str)
    if l:startIdx == -1
	return [a:expr, '']
    endif

    let l:endIdx = l:startIdx + len(a:str)
    return [strpart(a:expr, 0, l:startIdx), strpart(a:expr, l:endIdx)]
endfunction
function! ingo#str#split#MatchFirst( expr, pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:expr into the text before and after the first match of a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be split.
"   a:pattern	The pattern to split on; 'ignorecase' applies.
"* RETURN VALUES:
"   Tuple of [beforeMatch, matchedText, afterMatch].
"   When there's no match of a:pattern, the returned tuple is [a:expr, '', ''].
"******************************************************************************
    let l:startIdx = match(a:expr, a:pattern)
    if l:startIdx == -1
	return [a:expr, '', '']
    endif

    let l:endIdx = matchend(a:expr, a:pattern)
    return [strpart(a:expr, 0, l:startIdx), strpart(a:expr, l:startIdx, l:endIdx - l:startIdx), strpart(a:expr, l:endIdx)]
endfunction

function! ingo#str#split#AtPrefix( expr, prefix, ... )
"******************************************************************************
"* PURPOSE:
"   Split off a:prefix from the beginning of a:expr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr                  Text to be split.
"   a:prefix                The literal prefix text to remove.
"   a:isIgnoreCase          Optional flag whether to ignore case differences
"                           (default: false).
"   a:onPrefixNotExisting   Optional value to be returned when a:expr does not
"                           start with a:prefix.
"* RETURN VALUES:
"   Remainder of a:expr without a:prefix. Returns a:onPrefixNotExisting or
"   a:expr if the prefix doesn't exist.
"******************************************************************************
    return (ingo#str#StartsWith(a:expr, a:prefix, (a:0 ? a:1 : 0)) ?
    \   strpart(a:expr, len(a:prefix)) :
    \   (a:0 >= 2 ? a:2 : a:expr)
    \)
endfunction

function! ingo#str#split#AtSuffix( expr, suffix, ... )
"******************************************************************************
"* PURPOSE:
"   Split off a:suffix from the end of a:expr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr                  Text to be split.
"   a:suffix                The literal suffix text to remove.
"   a:onSuffixNotExisting   Optional value to be returned when a:expr does not
"                           end with a:suffix.
"* RETURN VALUES:
"   Remainder of a:expr without a:suffix. Returns a:onSuffixNotExisting or
"   a:expr if the suffix doesn't exist.
"******************************************************************************
    return (ingo#str#EndsWith(a:expr, a:suffix) ?
    \   strpart(a:expr, 0, len(a:expr) - len(a:suffix)) :
    \   (a:0 ? a:1 : a:expr)
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
