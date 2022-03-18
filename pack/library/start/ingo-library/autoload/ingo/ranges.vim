" ingo/ranges.vim: Functions for building ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#ranges#FromHeader( startLnum, endLnum, expr ) abort
"******************************************************************************
"* PURPOSE:
"   Each match of a:expr starts a range (and ends the previous one).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the cursor position.
"* INPUTS:
"   a:startLnum First line to be considered.
"   a:endLnum   Last line to be considered.
"   a:expr      Regular expression that identifies a header line(s).
"* RETURN VALUES:
"   List of ranges: [[startLnum, endLnum], ...]
"******************************************************************************
    let l:headerLnums = []
    call cursor(a:startLnum, 1)
    while line('.') <= a:endLnum
	let l:lnum = search(a:expr, 'cW', a:endLnum)
	if l:lnum == 0
	    break
	endif

	call add(l:headerLnums, l:lnum)

	if l:lnum == a:endLnum
	    break
	else
	    call cursor(l:lnum + 1, 1)
	endif
    endwhile

    let l:ranges = []
    for l:i in range(len(l:headerLnums))
	call add(l:ranges, [l:headerLnums[l:i], get(l:headerLnums,l:i + 1, a:endLnum + 1) - 1])
    endfor

    return l:ranges
endfunction

function! ingo#ranges#FromMatch( startLnum, endLnum, expr )
"******************************************************************************
"* PURPOSE:
"   Each (multi-line) match of a:expr defines a range.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the cursor position.
"* INPUTS:
"   a:startLnum First line to be considered.
"   a:endLnum   Last line to be considered.
"   a:expr      Regular expression that identifies a range. This likely includes
"               atoms like \n or \_s to match multiple lines.
"* RETURN VALUES:
"   List of ranges: [[startLnum, endLnum], ...]
"******************************************************************************
    let l:ranges = []
    call cursor(a:startLnum, 1)
    while line('.') <= a:endLnum
	let l:startLnum = search(a:expr, 'cW', a:endLnum)
	if l:startLnum == 0
	    break
	endif
	let l:endLnum = search(a:expr, 'ceW', a:endLnum)
	if l:endLnum == 0
	    break
	endif

	call add(l:ranges, [l:startLnum, l:endLnum])

	if l:endLnum == a:endLnum
	    break
	else
	    call cursor(l:endLnum + 1, 1)
	endif
    endwhile

    return l:ranges
endfunction

function! ingo#ranges#FromRange( startLnum, endLnum, range )
"******************************************************************************
"* PURPOSE:
"   Each a:range defines a range. Ranges are returned as a list of
"   non-overlapping effective ranges.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the cursor position.
"* INPUTS:
"   a:startLnum First line to be considered.
"   a:endLnum   Last line to be considered.
"   a:range     Range in any format supported by Vim, e.g. 'a,'b or
"		/^fun/,/^endfun/
"* RETURN VALUES:
"   List of ranges: [[startLnum, endLnum], ...]
"******************************************************************************
    if empty(a:range) | return [] | endif

    " With ranges, there can be overlapping regions. To emulate a fold-like
    " behavior (where folds can be contained in others), go through the list of
    " unique line numbers and the list of lines where ranges end, and build the
    " [startLnum, endLnum] list out of that.
    let [l:recordedLines, l:startLines, l:endLines, l:didClobberSearchHistory] = ingo#range#lines#Get(a:startLnum, a:endLnum, a:range)
    let l:linesInRange = sort(ingo#list#transform#str2nr(keys(l:recordedLines)), 'ingo#collections#numsort')
    call ingo#compat#uniq(l:endLines)
    let l:ranges = []
    while ! empty(l:endLines)
	let l:startLnum = remove(l:linesInRange, 0)
	let l:endLnum = remove(l:endLines, 0)
	if l:startLnum < l:endLnum
	    call add(l:ranges, [l:startLnum, l:endLnum])
	    call remove(l:linesInRange, 0, index(l:linesInRange, l:endLnum))
	endif
    endwhile

    return l:ranges
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
