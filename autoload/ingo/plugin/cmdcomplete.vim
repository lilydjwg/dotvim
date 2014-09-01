" ingo/plugin/cmdcomplete.vim: Functions to build simple command completions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.005.001	10-Apr-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

let s:completeFuncCnt = 0
function! ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc( argumentList, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a static list of possible arguments.
"* USAGE:
"   :execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(['foo', 'fox', 'bar']) ...
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:argumentList  List of possible arguments.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    if a:0
	let l:funcName = a:1
    else
	let s:completeFuncCnt += 1
	let l:funcName = printf('CompleteFunc%d', s:completeFuncCnt)
    endif

    execute
    \   printf('function! %s( ArgLead, CmdLine, CursorPos )', l:funcName) . "\n" .
    \   printf('    return filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', string(a:argumentList)) . "\n" .
    \          'endfunction'

    return l:funcName
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
