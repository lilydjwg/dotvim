" ingo/change.vim: Functions around the last changed text.
"
" DEPENDENCIES:
"   - ingo/cursor/move.vim autoload script
"   - ingo/pos.vim autoload script
"   - ingo/str/split.vim autoload script
"   - ingo/text.vim autoload script
"   - ingo/undo.vim autoload script
"
" Copyright: (C) 2018-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#change#IsLastAnInsertion( ... )
    let l:lastChangedText = (a:0 ? a:1 : ingo#text#Get(getpos("'[")[1:2], getpos("']")[1:2], 1))
    return (l:lastChangedText ==# @.)
endfunction

function! ingo#change#Get()
"******************************************************************************
"* PURPOSE:
"   Get the last inserted / changed text (between marks '[,']).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Last changed text, or empty string if there was no change yet or the last
"   change was a deletion.
"******************************************************************************
    let [l:startPos, l:endPos] = [getpos("'[")[1:2], getpos("']")[1:2]]

    " If the change was an insertion, the end of change mark is set _after_ the
    " last inserted character. For other changes (e.g. gU), the end of change
    " mark is _on_ the last changed character. We need to compare with register
    " . contents.
    let l:lastInsertedText = ingo#text#Get(l:startPos, l:endPos, 1)
    if ingo#change#IsLastAnInsertion(l:lastInsertedText)
	return l:lastInsertedText
    endif

    let l:lastChangedText = ingo#text#Get(l:startPos, l:endPos, 0)
    return l:lastChangedText
endfunction

function! ingo#change#IsCursorOnPreviousChange()
"******************************************************************************
"* PURPOSE:
"   Test whether the cursor is inside the area marked by the '[,'] marks.
"   (Depending on the type of change, it can be at the beginning, end, or
"   shortly before the end.)
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   1 if cursor is on previous change, 0 if not.
"******************************************************************************
    let [l:currentPos, l:startPos, l:endPos] = [getpos('.')[1:2], getpos("'[")[1:2], getpos("']")[1:2]]
    if ! ingo#pos#IsInside(l:currentPos, l:startPos, l:endPos)
	return 0
    endif

    if l:currentPos == l:endPos && ingo#change#IsLastAnInsertion()
	return 0    " Special case: After an insertion, the change mark is positioned one after the last inserted character.
    endif

    return 1
endfunction

function! ingo#change#JumpAfterEndOfChange()
    normal! g`]
    if ! ingo#change#IsLastAnInsertion()
	call ingo#cursor#move#Right()
    endif
endfunction

function! ingo#change#GetOverwrittenText()
"******************************************************************************
"* PURPOSE:
"   Get the text that was overwritten by the last change.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Overwritten text, or empty string.
"******************************************************************************
    let l:save_view = winsaveview()
    let [l:startPos, l:endPos] = [getpos("'["), getpos("']")]
    let [l:startLnum, l:endLnum] = [l:startPos[1], l:endPos[1]]
    let l:lastLnum = line('$')

    let l:textBeforeChange = ingo#text#Get([l:startLnum, 1], l:startPos[1:2], 1)
    let l:textAfterChange = ingo#text#Get(l:endPos[1:2], [l:endLnum, len(getline(l:endLnum))], 0)

    if ! ingo#change#IsLastAnInsertion() | let l:textAfterChange = matchstr(l:textAfterChange, '^.\zs.*') | endif
"****D echomsg string(l:textBeforeChange) string(l:textAfterChange)

    let l:undoChangeNumber = ingo#undo#GetChangeNumber()
    if l:undoChangeNumber < 0 | return '' | endif " Without undo, the overwritten text cannot be determined.
    try
	silent undo

	let l:changeOffset = l:lastLnum - line('$')
	let l:changedArea = join(getline(l:startLnum, l:endLnum - l:changeOffset), "\n")

	let l:startOfOverwritten = ingo#str#split#AtPrefix(l:changedArea, l:textBeforeChange)
	let l:overwritten = ingo#str#split#AtSuffix(l:startOfOverwritten, l:textAfterChange)

	return l:overwritten
    finally
	silent execute 'undo' l:undoChangeNumber

	" The :undo clobbered the change marks; restore them.
	call ingo#change#Set(l:startPos, l:endPos)

	" The :undo also affected the cursor position.
	call winrestview(l:save_view)
    endtry
endfunction

function! ingo#change#Set( startPos, endPos ) abort
"******************************************************************************
"* PURPOSE:
"   Sets the change marks to the passed area.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the change marks.
"* INPUTS:
"   a:startPos  [lnum, col] or [0, lnum, col, 0] of the start ('[) of the last
"               change.
"   a:endPos    [lnum, col] or [0, lnum, col, 0] of the end (']) of the last
"               change.
"* RETURN VALUES:
"   1 if successful, 0 if one position could not be set.
"******************************************************************************
    let l:result = 0
    let l:result += setpos("'[", ingo#pos#Make4(a:startPos))
    let l:result += setpos("']", ingo#pos#Make4(a:endPos))
    return (l:result == 0)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
