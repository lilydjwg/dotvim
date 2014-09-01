" ingo/cmdargs/register.vim: Functions for parsing a register name.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.001	10-Mar-2014	file creation

let s:writableRegisterExpr = '\([-a-zA-Z0-9"*+_/]\)'
function! ingo#cmdargs#register#ParseAppendedWritableRegister( arguments, ... )
    let l:directSeparator = (a:0 ? a:1 : '[[:alnum:][:space:]\\"|]\@![\x00-\xFF]')
    let l:matches = matchlist(a:arguments, '^\(.\{-}\)\%(\%(\%(' . l:directSeparator . '\)\@<=\s*\|\s\+\)' . s:writableRegisterExpr . '\)$')
    return (empty(l:matches) ? [a:arguments, ''] : l:matches[1:2])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
