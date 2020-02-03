" ingo/regexp/multi.vim: Functions around pattern multiplicity.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#multi#Expr()
"******************************************************************************
"* PURPOSE:
"   REturn a regular expression that matches any multi.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\*\|\\[+=?]\|\\{-\?\d*,\?\d*}\|\\@\%(>\|=\|!\|<=\|<!\)\)'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
