" ingo/regexp/pairs.vim: Functions for skipping intermediate start-end pairs.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.022.001	20-Aug-2014	file creation

function! ingo#regexp#pairs#MatchEnd( expr, startPattern, endPattern, ... )
"******************************************************************************
"* PURPOSE:
"   Search for the match of the end of a pair, skipping intermediate start-end
"   pairs in between.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to match.
"   a:startPattern  Pattern that matches the start of a pair.
"   a:endPattern    Pattern that matches the end of a pair.
"   a:start         Optional byte index into a:expr from where to start.
"* RETURN VALUES:
"   Byte index of the start of the a:endPattern that belongs to a:startPattern,
"   skipping nested intermediate pairs. -1 if not such match.
"******************************************************************************
    let l:idx = (a:0 ? a:1 : 0)
    let l:pairCnt = 0
    while 1
	let l:startIdx = match(a:expr, a:startPattern, l:idx)
	let l:endIdx = match(a:expr, a:endPattern, l:idx)

	if l:startIdx == -1 && l:endIdx == -1
	    return -1
	elseif l:startIdx != -1 && l:startIdx < l:endIdx
	    let l:pairCnt += 1
	    let l:idx = l:startIdx + len(matchstr(a:expr, '\%' . (l:startIdx + 1) . 'c.'))
	elseif l:endIdx != -1
	    let l:pairCnt -= 1
	    if l:pairCnt <= 0
		return l:endIdx
	    endif
	    let l:idx = l:endIdx + len(matchstr(a:expr, '\%' . (l:endIdx + 1) . 'c.'))
	else
	    throw 'ASSERT: Never reached'
	endif
    endwhile
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
