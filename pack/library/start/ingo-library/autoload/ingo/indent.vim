" ingo/indent.vim: Functions for working with indent.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.002	02-Dec-2016	Add ingo#indent#Split(), a simpler version of
"				ingo#comments#SplitIndentAndText().
"   1.028.001	25-Nov-2016	file creation

function! ingo#indent#RangeSeveralTimes( firstLnum, lastLnum, command, times )
    for l:i in range(a:times)
	silent execute a:firstLnum . ',' . a:lastLnum . a:command
    endfor
endfunction

function! ingo#indent#GetIndent( lnum )
    return matchstr(getline(a:lnum), '^\s*')
endfunction
function! ingo#indent#GetIndentLevel( lnum )
    return indent(a:lnum) / &l:shiftwidth
endfunction
function! ingo#indent#Split( lnum )
"******************************************************************************
"* PURPOSE:
"   Split the line into any leading indent, and the text after it.
"* SEE ALSO:
"   ingo#comments#SplitIndentAndText() also considers any comment prefix as part
"   of the indent.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Number of the line to be split.
"* RETURN VALUES:
"   Returns [a:indent, a:text].
"******************************************************************************
    return matchlist(getline(a:lnum), '^\(\s*\)\(.*\)$')[1:2]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
