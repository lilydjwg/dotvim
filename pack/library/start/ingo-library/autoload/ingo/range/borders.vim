" ingo/range/borders.vim: Functions for determining ranges at the borders of the buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	13-Jul-2016	file creation

function! ingo#range#borders#StartAndEndRange( startOffset, endOffset )
"******************************************************************************
"* PURPOSE:
"   Determine non-overlapping range(s) for a:startOffset lines from the start of
"   the current buffer, and a:endOffset lines from the end of the current
"   buffer.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startOffset Number of lines to get from the start.
"   a:endOffset Number of lines to get from the end.
"* RETURN VALUES:
"   List of ranges, in the form ['1,3', '8,$']
"******************************************************************************
    let l:ranges = []
    let l:lastStartLnum = min([line('$'), a:startOffset])
    if a:startOffset > 0
	call add(l:ranges, '1,' . l:lastStartLnum)
    endif

    let l:firstEndLnum = max([1, line('$') - a:endOffset + 1])
    let l:firstEndLnum = max([l:lastStartLnum + 1, l:firstEndLnum])
    if l:firstEndLnum <= line('$')
	call add(l:ranges, l:firstEndLnum . ',$')
    endif
    return l:ranges
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
