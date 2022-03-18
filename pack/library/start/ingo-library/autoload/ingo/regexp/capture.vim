" ingo/regexp/capture.vim: Functions to work with capture groups.
"
" DEPENDENCIES:
"   - ingo/subst.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#capture#MakeNonCapturing( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Convert all / some capturing groups in a:pattern into non-capturing groups.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression.
"   a:indices   Optional List of 0-based indices of matches that will be
"               converted. If omitted or String "g", all matches will be
"               converted.
"* RETURN VALUES:
"   Converted regular expression without any capturing groups.
"******************************************************************************
    return ingo#subst#Indexed(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\(', '\\%(', (a:0 ? a:1 : 'g'))
endfunction
function! ingo#regexp#capture#MakeCapturing( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Convert all / some non-capturing groups in a:pattern into capturing groups.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression.
"   a:indices   Optional List of 0-based indices of matches that will be
"               converted. If omitted or String "g", all matches will be
"               converted.
"* RETURN VALUES:
"   Converted regular expression without any non-capturing groups.
"******************************************************************************
    return ingo#subst#Indexed(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%(', '\\(', (a:0 ? a:1 : 'g'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
