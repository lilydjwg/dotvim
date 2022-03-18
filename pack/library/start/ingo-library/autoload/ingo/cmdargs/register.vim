" ingo/cmdargs/register.vim: Functions for parsing a register name.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:writableRegisterExpr = '\([-a-zA-Z0-9"*+_/]\)'
function! s:GetDirectSeparator( optionalArguments )
    return (len(a:optionalArguments) > 0 && a:optionalArguments[0] isnot [] ?
    \   (empty(a:optionalArguments[0]) ?
    \       '\%$\%^' :
    \       a:optionalArguments[0]
    \   ) :
    \   '[[:alnum:][:space:]\\"|]\@![\x00-\xFF]'
    \)
endfunction

function! ingo#cmdargs#register#ParseAppendedWritableRegister( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments into any stuff and a writable register at the end,
"   separated by non-alphanumeric character or whitespace (or the optional
"   a:directSeparator).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:directSeparator   Optional regular expression for the separator (parsed
"			into text) between the text and register (with optional
"			whitespace in between; mandatory whitespace is always an
"			alternative). Defaults to any non-alphanumeric
"			character (also when an empty List is passed). If the
"			empty String: There must be whitespace between text and
"			register.
"   a:isPreferText      Optional flag that if the arguments consist solely of a
"                       register, whether this is counted as text (1, default)
"                       or as a sole register (0).
"* RETURN VALUES:
"   [text, register], or [a:arguments, ''] if no register could be parsed.
"******************************************************************************
    let l:matches = matchlist(a:arguments, '^\(.\{-}\)\%(\%(\%(' . s:GetDirectSeparator(a:000) . '\)\@<=\s*\|\s\+\)' . s:writableRegisterExpr . '\)$')
    return (empty(l:matches) ?
    \   (a:0 >= 2 && ! a:2 && a:arguments =~# '^' . s:writableRegisterExpr . '$' ?
    \       ['', a:arguments] :
    \       [a:arguments , '']
    \   ) :
    \   l:matches[1:2]
    \)
endfunction

function! ingo#cmdargs#register#ParsePrependedWritableRegister( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments into a writable register at the beginning, and any
"   following stuff, separated by non-alphanumeric character or whitespace (or
"   the optional a:directSeparator).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:directSeparator   Optional regular expression for the separator (parsed
"			into text) between the text and register (with optional
"			whitespace in between; mandatory whitespace is always an
"			alternative). Defaults to any non-alphanumeric
"			character (also when an empty List is passed). If the
"			empty String: There must be whitespace between text and
"			register.
"   a:isPreferText      Optional flag that if the arguments consist solely of a
"                       register, whether this is counted as text (1, default)
"                       or as a sole register (0).
"* RETURN VALUES:
"   [register, text], or ['', a:arguments] if no register could be parsed.
"******************************************************************************
    let l:matches = matchlist(a:arguments, '^' . s:writableRegisterExpr . '\%(\%(\s*' . s:GetDirectSeparator(a:000) . '\)\@=\|\s\+\)\(.*\)$')
    return (empty(l:matches) ?
    \   (a:0 >= 2 && ! a:2 && a:arguments =~# '^' . s:writableRegisterExpr . '$' ?
    \       [a:arguments , ''] :
    \       ['', a:arguments]
    \   ) :
    \   l:matches[1:2]
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
