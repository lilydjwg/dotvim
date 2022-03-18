" ingo/line/replace.vim: Functions to replace text in a single line.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	22-Dec-2016	file creation

function! ingo#line#replace#Substitute( lnum, pat, sub, flags )
"******************************************************************************
"* PURPOSE:
"   Substitute a pattern in a single line in the current buffer. Low-level
"   alternative to :substitute without the need to suppress messages, undo
"   search history clobbering, cursor move.
"* SEE ALSO:
"   - ingo#lines#replace#Substitute() handles multiple lines, but is more
"     costly.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not handle inserted newlines; i.e. no additional lines will be created,
"   the newline will be persisted as-is (^@).
"* EFFECTS / POSTCONDITIONS:
"   Updates a:lnum.
"* INPUTS:
"   a:lnum  Existing line number.
"   a:pat   Regular expression to match.
"   a:sub   Replacement string.
"   a:flags "g" for global replacement.
"* RETURN VALUES:
" If this succeeds, 0 is returned.  If this fails (most likely because a:lnum is
" invalid) 1 is returned.
"******************************************************************************
    return setline(a:lnum, substitute(getline(a:lnum), a:pat, a:sub, a:flags))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
