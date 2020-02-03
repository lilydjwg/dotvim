" ingo/comments/indent.vim: Functions for indents around commented lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#comments#indent#Total( line ) abort
"******************************************************************************
"* PURPOSE:
"   Returns the sum of leading indent, the width of the comment prefix plus the
"   indent after it (counted in screen cells). Like indent(), but considers a
"   comment prefix as well. If there's no comment, just returns the ordinary
"   indent.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:line  The line to be analyzed.
"* RETURN VALUES:
"   Indent counted in spaces.
"******************************************************************************
    return ingo#compat#strdisplaywidth(ingo#comments#SplitIndentAndText(a:line)[0])
endfunction

function! ingo#comments#indent#AfterComment( line ) abort
"******************************************************************************
"* PURPOSE:
"   Returns the width of the comment prefix plus the indent after it (counted in
"   screen cells). Like indent(), but only for the stuff after the comment
"   prefix (including the prefix itself). If there's no comment, just returns
"   the ordinary indent.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:line  The line to be analyzed.
"* RETURN VALUES:
"   Indent counted in spaces.
"******************************************************************************
    let [l:indentBefore, l:commentPrefix, l:indentAfter, l:text, l:isBlankRequired] = ingo#comments#SplitAll(a:line)

    let l:beforeWidth = ingo#compat#strdisplaywidth(l:indentBefore)
    if empty(l:commentPrefix . l:indentAfter)
	return l:beforeWidth
    endif

    let l:totalWidth = ingo#compat#strdisplaywidth(l:indentBefore . l:commentPrefix . l:indentAfter)
    return l:totalWidth - l:beforeWidth
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
