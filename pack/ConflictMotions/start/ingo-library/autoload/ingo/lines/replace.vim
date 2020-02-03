" replace.vim: Functions to replace text in lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	23-Dec-2016	file creation

function! ingo#lines#replace#Substitute( startLnum, endLnum, pat, sub, flags )
"******************************************************************************
"* PURPOSE:
"   Substitute a pattern in lines in the current buffer. Low-level
"   alternative to :[range]substitute without the need to suppress messages,
"   undo search history clobbering, cursor move.
"* SEE ALSO:
"   - ingo#line#replace#Substitute() is a cheaper alternative that only handles
"     a single line, though.
"* ASSUMPTIONS / PRECONDITIONS:
"   Handles inserted newlines and removed lines.
"* EFFECTS / POSTCONDITIONS:
"   Updates the buffer.
"* INPUTS:
"   a:startLnum  Existing line number.
"   a:endLnum  Existing line number.
"   a:pat   Regular expression to match. It is applied to all lines joined via
"	    \n; the last line does not end in \n. That means that even if you
"	    match everything in all lines (.*), and replace it with the empty
"	    string, a single empty line will remain.
"   a:sub   Replacement string.
"   a:flags "g" for global replacement.
"* RETURN VALUES:
" If this succeeds, 0 is returned.  If this fails 1 is returned.
"******************************************************************************
    let l:lines = getline(a:startLnum, a:endLnum)
    if empty(l:lines) | return 1 | endif
    let l:lineNum = len(l:lines)

    let l:newLines = split(substitute(join(l:lines, "\n"), a:pat, a:sub, a:flags), '\n', 1)
    let l:newLineNum = len(l:newLines)

    " Update existing lines first, then handle any additions / deletions.
    for l:i in range(min([l:lineNum, l:newLineNum]))
	call setline(a:startLnum + l:i, l:newLines[l:i])
    endfor
    if l:newLineNum < l:lineNum
	" We have less lines now; remove the surplus original ones.
	" Unfortunately, there's no low-level function for deletion, so we need
	" to use :delete.
	let l:save_view = winsaveview()
	let l:save_foldenable = &l:foldenable
	setlocal nofoldenable
	    silent! execute printf('keepjumps %d,%ddelete _', a:startLnum + l:newLineNum, a:endLnum)
	let &l:foldenable = l:save_foldenable
	call winrestview(l:save_view)
	return 0
    elseif l:newLineNum > l:lineNum
	" Additional lines need to be appended.
	return append(a:endLnum, l:newLines[l:lineNum : ])
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
