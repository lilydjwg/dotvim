" ingo/err.vim: Functions for proper Vim error handling with :echoerr.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.002.001	08-Mar-2013	file creation

"******************************************************************************
"* PURPOSE:
"   Custom commands should use :echoerr for error reporting, because that also
"   properly aborts a command sequence. The echoing via ingo#msg#ErrorMsg() does
"   not provide this and is therefore deprecated (though sufficient for most
"   purposes).
"   This set of functions solves the problem that the error is often raised in a
"   function, but the :echoerr has to be done directly from the :command (to
"   avoid the printing of the multi-line error source). One could return the
"   error string from the function and then perform the :echoerr on non-empty
"   result, but that requires a temporary (global) variable and is cumbersome.
"* USAGE:
"   Inside your function, invoke one of the ingo#err#Set...() functions.
"   Indicate to the invoking :command via a boolean flag whether the command
"   succeeded. On failure, :echoerr the stored error message via ingo#err#Get().
"	command! Foo if ! Foo#Bar() | echoerr ingo#err#Get() | endif
"******************************************************************************
let s:errmsg = ''
function! ingo#err#Get()
    return s:errmsg
endfunction
function! ingo#err#Clear()
    let s:errmsg = ''
endfunction
function! ingo#err#Set( errmsg )
    let s:errmsg = a:errmsg
endfunction
function! ingo#err#SetVimException()
    call ingo#err#Set(ingo#msg#MsgFromVimException())
endfunction
function! ingo#err#SetCustomException( customPrefixPattern )
    call ingo#err#Set(substitute(v:exception, printf('^\%%(%s\):\s*', a:customPrefixPattern), '', ''))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
