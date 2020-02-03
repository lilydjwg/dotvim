" ingo/plugin/marks.vim: Functions for reserving marks for plugin use.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#plugin#marks#Reuse( pos, ... )
"******************************************************************************
"* PURPOSE:
"   Locate (for reuse) an existing mark at a:pos.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pos               Position, either [lnum, col] or the full [bufnum, lnum,
"			col, off].
"   a:consideredMarks   Optional String or List of marks that are considered.
"			Defaults to lowercase and uppercase marks a-zA-Z.
"* RETURN VALUES:
"   Mark name, or empty String.
"******************************************************************************
    let l:consideredMarks = (a:0 ? a:1 : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
    let l:pos = (len(a:pos) < 4 ? [0] + a:pos[0:1] + [0] : a:pos[0:3])

    for l:mark in (type(l:consideredMarks) == type([]) ? l:consideredMarks : split(l:consideredMarks, '\zs'))
	let l:targetPos = l:pos
	if l:mark =~# '\u'
	    if l:pos[0] == 0
		" Uppercase marks have the buffer number as the first element.
		let l:targetPos = [bufnr('')] + l:pos[1:]
	    endif
	else
	    if l:pos[0] != 0 && l:pos[0] != bufnr('')
		" The searched-for position is in another buffer, so local marks
		" must not be considered.
		continue
	    else
		" Lowercase marks have 0 as the first element.
		let l:targetPos[0] = 0
	    endif
	endif

	if getpos("'" . l:mark) == l:targetPos
	    return l:mark
	endif
    endfor

    return ''
endfunction

function! ingo#plugin#marks#FindUnused( ... )
"******************************************************************************
"* PURPOSE:
"   Find the next unused mark and return it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the mark to avoid finding them again. The client will probably override
"   the mark location, anyway.
"* INPUTS:
"   a:consideredMarks   Optional String or List of marks that are considered.
"			Defaults to lowercase and uppercase marks a-zA-Z.
"* RETURN VALUES:
"   Mark name. Throws exception if no mark is available.
"******************************************************************************
    let l:consideredMarks = (a:0 && ! empty(a:1) ? a:1 : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')

    for l:mark in (type(l:consideredMarks) == type([]) ? l:consideredMarks : split(l:consideredMarks, '\zs'))
	if getpos("'" . l:mark)[1:2] == [0, 0]
	    " Reserve mark so that the next invocation doesn't return it again.
	    call setpos("'" . l:mark, getpos('.'))
	    return l:mark
	endif
    endfor
    throw 'ReserveMarks: Ran out of unused marks!'
endfunction

function! ingo#plugin#marks#Reserve( number, ... )
"******************************************************************************
"* PURPOSE:
"   Reserve a:number of available marks for use and return undo information.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets reserved marks to avoid finding them again. The client will probably
"   override the mark location, anyway.
"* INPUTS:
"   a:number	Number of marks to be reserved.
"   a:marks	Optional string of concatenated marks. If passed, those marks
"               will be taken (and current positions will be saved in the undo
"               information). If empty or omitted, marks from
"               g:IngoLibrary_Marks (if defined) will be used. If that also is
"               empty or undefined, unused marks will be used (this is the
"               default).
"* RETURN VALUES:
"   reservedMarksRecord. Use keys(reservedMarksRecord) to get the names of the
"   reserved marks.  The records object must also be passed back to
"   ingo#plugin#marks#Unreserve().
"   Throws exception if no mark is available (and no a:marks had been passed).
"******************************************************************************
    let l:marksRecord = {}
    for l:cnt in range(0, (a:number - 1))
	let l:mark = strpart((a:0 ? a:1 : (exists('g:IngoLibrary_Marks') ? g:IngoLibrary_Marks : '')), l:cnt, 1)
	if empty(l:mark)
	    let l:unusedMark = ingo#plugin#marks#FindUnused()
	    let l:marksRecord[l:unusedMark] = [0, 0, 0, 0]
	else
	    let l:marksRecord[l:mark] = getpos("'" . l:mark)
	endif
    endfor
    return l:marksRecord
endfunction
function! ingo#plugin#marks#Unreserve( marksRecord )
"******************************************************************************
"* PURPOSE:
"   Unreserve marks and restore the original mark position.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Resets reserved marks.
"* INPUTS:
"   a:marksRecord   Undo information object handed out by
"		    ingo#plugin#marks#Reserve().
"* RETURN VALUES:
"   None.
"******************************************************************************
    for l:mark in keys(a:marksRecord)
	call setpos("'" . l:mark, a:marksRecord[l:mark])
    endfor
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
