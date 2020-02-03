" ingo/window/dimensions.vim: Functions for querying aspects of window dimensions.
"
" DEPENDENCIES:
"   - ingo/folds.vim autoload script
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim

" Determine the number of lines in the passed range that aren't folded away;
" folded ranges count only as one line. Visible doesn't mean "currently
" displayed in the window"; for that, you could create the difference of the
" start and end winline(), or use ingo#window#dimensions#DisplayedLines().
function! ingo#window#dimensions#NetVisibleLines( startLine, endLine )
    return a:endLine - a:startLine + 1 - ingo#folds#FoldedLines(a:startLine, a:endLine)[1]
endfunction

" Determine the range of lines that are currently displayed in the window.
function! ingo#window#dimensions#DisplayedLines()
    let l:startLine = winsaveview().topline
    let l:endLine = l:startLine
    let l:screenLineCnt = 0
    while l:screenLineCnt < winheight(0)
	let l:lastFoldedLine = foldclosedend(l:endLine)
	if l:lastFoldedLine == -1
	    let l:endLine += 1
	else
	    let l:endLine = l:lastFoldedLine + 1
	endif

	let l:screenLineCnt += 1
    endwhile

    return [l:startLine, l:endLine - 1]
endfunction



function! ingo#window#dimensions#GetNumberWidth( isGetAbsoluteNumberWidth )
"******************************************************************************
"* PURPOSE:
"   Get the width of the number column for the current window.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isGetAbsoluteNumberWidth	If true, assumes absolute number are requested.
"				Otherwise, determines whether 'number' or
"				'relativenumber' are actually set and calculates
"				based on the actual window settings.
"* RETURN VALUES:
"   Width for displaying numbers. To use the result for printf()-style
"   formatting of numbers, subtract 1:
"   printf('%' . (ingo#window#dimensions#GetNumberWidth(1) - 1) . 'd', l:lnum)
"******************************************************************************
    let l:maxNumber = 0
    " Note: 'numberwidth' is only the minimal width, can be more if...
    if &l:number || a:isGetAbsoluteNumberWidth
	" ...the buffer has many lines.
	let l:maxNumber = line('$')
    elseif exists('+relativenumber') && &l:relativenumber
	" ...the window width has more digits.
	let l:maxNumber = winheight(0)
    endif
    if l:maxNumber > 0
	let l:actualNumberWidth = strlen(string(l:maxNumber)) + 1
	return (l:actualNumberWidth > &l:numberwidth ? l:actualNumberWidth : &l:numberwidth)
    else
	return 0
    endif
endfunction

" Determine the number of virtual columns of the current window that are not
" used for displaying buffer contents, but contain window decoration like line
" numbers, fold column and signs.
function! ingo#window#dimensions#WindowDecorationColumns()
    let l:decorationColumns = 0
    let l:decorationColumns += ingo#window#dimensions#GetNumberWidth(0)

    if has('folding')
	let l:decorationColumns += &l:foldcolumn
    endif

    if has('signs')
	redir => l:signsOutput
	silent execute 'sign place buffer=' . bufnr('')
	redir END

	" The ':sign place' output contains two header lines.
	" The sign column is fixed at two columns.
	if len(split(l:signsOutput, "\n")) > 2
	    let l:decorationColumns += 2
	endif
    endif

    return l:decorationColumns
endfunction

" Determine the number of virtual columns of the current window that are
" available for displaying buffer contents.
function! ingo#window#dimensions#NetWindowWidth()
    return winwidth(0) - ingo#window#dimensions#WindowDecorationColumns()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
