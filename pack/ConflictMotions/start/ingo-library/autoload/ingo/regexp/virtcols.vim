" ingo/regexp/virtcols.vim: Functions for regular expressions matching screen columns.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.001	01-Apr-2015	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#regexp#virtcols#ExtractCells( virtcol, width, isAllowSmaller )
"******************************************************************************
"* PURPOSE:
"   Assemble a regular expression that matches screen columns starting from
"   a:virtcol of a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:virtcol   First virtual column (first column is 1); the character must
"		begin exactly at that column.
"   a:width     Width in screen columns.
"   a:isAllowSmaller    Boolean flag whether less characters can be matched if
"			the end doesn't fall on a character border, or there
"			aren't that many characters. Else, exactly a:width
"			screen columns must be matched.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    if a:virtcol < 1
	throw 'ExtractCells: Column must be at least 1'
    endif
    return '\%' . a:virtcol . 'v.*' .
    \   (a:isAllowSmaller ?
    \       '\%<' . (a:virtcol + a:width + 1) . 'v' :
    \       '\%' . (a:virtcol + a:width) . 'v'
    \)
endfunction

function! s:Before( val ) abort
    return a:val - 1
endfunction
function! s:After( val ) abort
    return a:val + 1
endfunction
function! ingo#regexp#virtcols#StartAnchorPattern( lnum, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Assemble regular expression atoms that anchors matches to the start of
"   passed a:lnum [, a:virtcol].
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum      First line to accept.
"   a:virtcol   First screen column to accept.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\%>' . s:Before(a:lnum) . 'l' .
    \   (a:0 ? '\%>' . s:Before(a:1) . 'v' : '')
endfunction
function! ingo#regexp#virtcols#EndAnchorPattern( lnum, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Assemble regular expression atoms that anchors matches to the end of
"   passed a:lnum [, a:virtcol].
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum      Last line to accept.
"   a:virtcol   Last screen column to accept.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\%<' . s:After(a:lnum) . 'l' .
    \   (a:0 ? '\%<' . s:After(a:1) . 'v' : '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
