" ingo/range/Lines.vim: Functions for retrieving line numbers of ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	10-Jun-2014	file creation from
"				autoload/PatternsOnText/Ranges.vim

function! s:RecordLine( records, startLnum, endLnum )
    let l:lnum = line('.')
    if l:lnum < a:startLnum || l:lnum > a:endLnum
	let s:didRecord = 0
	return
    endif

    let a:records[l:lnum] = 1
    let s:didRecord = 1
endfunction
function! s:RecordLines( records, startLines, endLines, startLnum, endLnum ) range
    execute printf('%d,%dcall s:RecordLine(a:records, a:startLnum, a:endLnum)', a:firstline, a:lastline)
    if s:didRecord
	call add(a:startLines, max([a:firstline, a:startLnum]))
	call add(a:endLines, min([a:lastline, a:endLnum]))
    endif
endfunction
function! ingo#range#lines#Get( startLnum, endLnum, range )
"******************************************************************************
"* PURPOSE:
"   Determine the line numbers and start and end lines of a:range that fall
"   inside a:startLnum and a:endLnum.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startLnum First line number to be considered.
"   a:endLnum   Last line number to be considered.
"   a:range     Range in any format supported by Vim, e.g. 'a,'b or
"		/^fun/,/^endfun/
"* RETURN VALUES:
"   [recordedLines, startLines, endLines, didClobberSearchHistory]
"   recordedLines   Dictionary with all line numbers that fall into the range(s)
"		    as keys.
"   startLines      List of line numbers where a range starts. Can contain
"		    multiple elements if a /pattern/ range is used.
"   endLines        List of line numbers where a range ends.
"   didClobberSearchHistory Flag whether a command was used that has added a
"			    temporary pattern to the search history. If true,
"			    call histdel('search', -1) at the end of the client
"			    function once.
"******************************************************************************
    let l:recordedLines = {}
    let l:startLines = []
    let l:endLines = []

    if a:range =~# '^[/?]'
	" For patterns, we need :global to find _all_ (not just the first)
	" matching ranges.
	execute printf('silent! %d,%dglobal %s call <SID>RecordLines(l:recordedLines, l:startLines, l:endLines, %d, %d)',
	\  a:startLnum, a:endLnum,
	\  a:range,
	\  a:startLnum, a:endLnum
	\)
	let l:didClobberSearchHistory = 1
    else
	" For line number, marks, etc., we can just record them (limited to
	" those that fall into the command's range).
	execute printf('silent! %s call <SID>RecordLines(l:recordedLines, l:startLines, l:endLines, %d, %d)',
	\  a:range,
	\  a:startLnum, a:endLnum
	\)
	let l:didClobberSearchHistory = 0
    endif

    return [l:recordedLines, l:startLines, l:endLines, l:didClobberSearchHistory]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
