" ingo/plugin/marks.vim: Functions for reserving marks for plugin use.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.010.002	08-Jul-2013	Move into ingo-library.
"	001	29-Sep-2010	file creation from CommandWithMutableRange.vim

function! s:FindUnusedMark()
    for l:mark in split('abcdefghijklmnopqrstuvwxyz', '\zs')
	if getpos("'" . l:mark) == [0, 0, 0, 0]
	    " Reserve mark so that the next invocation doesn't return it again.
	    execute 'normal! m' . l:mark
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
"* RETURN VALUES:
"   l:reservedMarksRecord   Marks record. Use keys(l:reservedMarksRecord) to get
"			    the names of the reserved marks.  The records object
"			    must also be passed back to
"			    ingo#plugin#marks#Unreserve().
"******************************************************************************
    let l:marksRecord = {}
    for l:cnt in range(0, (a:number - 1))
	let l:mark = strpart((a:0 ? a:1 : ''), l:cnt, 1)
	if empty(l:mark)
	    let l:unusedMark = s:FindUnusedMark()
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
