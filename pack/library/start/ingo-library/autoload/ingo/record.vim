" ingo/record.vim: Functions for recording the current position / editing state.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.002	23-Mar-2016	Add optional a:characterOffset to
"				ingo#record#PositionAndLocation().
"   1.020.001	30-May-2014	file creation

function! ingo#record#Position( isRecordChange )
    " The position record consists of the current cursor position, the buffer
    " number and optionally its current change state. When this position record
    " is assigned to a window-local variable, it is also linked to the current
    " window and tab page.
    return getpos('.') + [bufnr('')] + (a:isRecordChange ? [b:changedtick] : [])
endfunction
function! ingo#record#PositionAndLocation( isRecordChange, ... )
"******************************************************************************
"* PURPOSE:
"   The position record consists of the current cursor position, the buffer,
"   window and tab page number and optionally the buffer's current change state.
"   As soon as you make an edit, move to another buffer or even the same buffer
"   in another tab page or window (or as a minor side effect just close a window
"   above the current), the position changes.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isRecordChange    Flag whether b:changedtick should be part of the record.
"   a:characterOffset   Offset in characters from the current cursor position.
"			Can be -1, 0, or 1.
"* RETURN VALUES:
"   List of recorded values (to be compared with later results from this
"   function).
"******************************************************************************
    let l:pos = getpos('.')

    if a:0
	if a:1 == 1
	    let l:pos[2] += len(ingo#text#GetChar(l:pos[1:2]))
	elseif a:1 == -1
	    let l:pos[2] -= len(ingo#text#GetCharBefore(l:pos[1:2]))
	elseif a:1 != 0
	    throw 'ASSERT: Offsets other than -1, 0, 1 not supported yet'
	endif
    endif

    return l:pos + [bufnr(''), winnr(), tabpagenr()] + (a:isRecordChange ? [b:changedtick] : [])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
