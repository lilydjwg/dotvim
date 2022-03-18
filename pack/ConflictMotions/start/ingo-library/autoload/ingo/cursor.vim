" ingo/cursor.vim: Functions for the cursor position.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#cursor#Set( lnum, virtcol )
"******************************************************************************
"* PURPOSE:
"   Set the cursor position to a virtual column, not the byte count like
"   cursor() does.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Re-positions the cursor.
"* INPUTS:
"   a:lnum  Line number; if {lnum} is zero, the cursor will stay in the current
"	    line.
"   a:virtcol   Screen column; if no such column is available, will put the
"		cursor on the last character in the line.
"* RETURN VALUES:
"   1 if the desired virtual column has been reached; 0 otherwise.
"******************************************************************************
    if a:lnum != 0
	call cursor(a:lnum, 0)
    endif
    execute 'normal!' a:virtcol . '|'
    return (virtcol('.') == a:virtcol)
endfunction

function! ingo#cursor#IsAtEndOfLine( ... )
"******************************************************************************
"* PURPOSE:
"   Tests whether the cursor is on (or behind, with 'virtualedit') the last
"   character of the current line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:mark  Optional mark containing the current position; this should be
"	    located in the current line to make sense!
"* RETURN VALUES:
"   1 if at the end of the current line, 0 otherwise.
"******************************************************************************
    let l:mark = (a:0 ? a:1 : '.')
    return (col(l:mark) + len(matchstr(getline(l:mark), '.$')) >= col('$'))    " I18N: Cannot just add 1; need to consider the byte length of the last character in the line.

    " This won't work with :set virtualedit=all, when the cursor is after the
    " physical end of the line.
    "return (search('\%#.$', 'cn', line('.')) > 0)
endfunction
function! ingo#cursor#IsBeyondEndOfLine( ... )
"******************************************************************************
"* PURPOSE:
"   Tests whether the cursor is behind (possible with 'virtualedit') the last
"   character of the current line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:mark  Optional mark containing the current position; this should be
"	    located in the current line to make sense!
"* RETURN VALUES:
"   1 if beyond the end of the current line, 0 otherwise.
"******************************************************************************
    let l:mark = (a:0 ? a:1 : '.')
    return (col(l:mark) + len(matchstr(getline(l:mark), '.$')) > col('$'))    " I18N: Cannot just add 1; need to consider the byte length of the last character in the line.
endfunction

function! ingo#cursor#IsOnWhitespace() abort
    return search('\%#\s', 'cnW', line('.')) != 0
endfunction
function! ingo#cursor#IsOnEmptyLine() abort
    return empty(getline('.'))
endfunction


function! ingo#cursor#StartInsert( ... )
    let l:isAtEndOfLine = (a:0 ? a:1 : ingo#cursor#IsAtEndOfLine())
    if l:isAtEndOfLine
	startinsert!
    else
	startinsert
    endif
endfunction

function! ingo#cursor#StartAppend( ... )
"******************************************************************************
"* PURPOSE:
"   Start appending just after executing this command. Works like typing "a" in
"   normal mode.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Starts insert mode.
"* INPUTS:
"   a:isAtEndOfLine Optional flag whether the cursor is at the end of the line.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:isAtEndOfLine = (a:0 ? a:1 : ingo#cursor#IsAtEndOfLine())
    if l:isAtEndOfLine
	startinsert!
    else
	normal! l
	startinsert
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
