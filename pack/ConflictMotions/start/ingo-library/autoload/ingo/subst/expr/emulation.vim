" ingo/subst/expr/emulation.vim: Function to emulate sub-replace-expression for recursive use.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Deprecated since 1.043.
" Use ingo#compat#substitution#RecursiveSubstitutionExpression() instead.
function! ingo#subst#expr#emulation#Substitute( expr, pat, sub, flags )
    return ingo#compat#substitution#RecursiveSubstitutionExpression(a:expr, a:pat, a:sub, a:flags)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
