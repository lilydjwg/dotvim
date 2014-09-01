" ingo/msg.vim: Functions for Vim errors and warnings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.006	05-May-2014	Add optional a:isBeep argument to
"				ingo#msg#ErrorMsg().
"   1.009.005	21-Jun-2013	:echomsg sets v:statusmsg itself when there's no
"				current highlighting; no need to do that then in
"				ingo#msg#StatusMsg(). Instead, allow to set a
"				custom highlight group for the message.
"				Add ingo#msg#HighlightMsg() and use that in the
"				other functions.
"   1.009.004	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.006.003	06-May-2013	Add ingo#msg#StatusMsg().
"   1.003.002	13-Mar-2013	Add ingo#msg#ShellError().
"   1.000.001	22-Jan-2013	file creation

function! ingo#msg#HighlightMsg( text, hlgroup )
    execute 'echohl' a:hlgroup
    echomsg a:text
    echohl None
endfunction

function! ingo#msg#StatusMsg( text, ... )
"******************************************************************************
"* PURPOSE:
"   Echo a message, optionally with a custom highlight group, and store the
"   message in v:statusmsg. (Vim only does this automatically when there's no
"   active highlighting.)
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  The message to be echoed and added to the message history.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if a:0
	let v:statusmsg = a:text
	call ingo#msg#HighlightMsg(a:text, a:1)
    else
	echohl None
	echomsg a:text
    endif
endfunction

function! ingo#msg#WarningMsg( text )
    let v:warningmsg = a:text
    call ingo#msg#HighlightMsg(v:warningmsg, 'WarningMsg')
endfunction

function! ingo#msg#ErrorMsg( text, ... )
    let v:errmsg = a:text
    call ingo#msg#HighlightMsg(v:errmsg, 'ErrorMsg')

    if a:0 && a:1
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    endif
endfunction

function! ingo#msg#MsgFromVimException()
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away.
    return substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', '')
endfunction
function! ingo#msg#VimExceptionMsg()
    call ingo#msg#ErrorMsg(ingo#msg#MsgFromVimException())
endfunction
function! ingo#msg#CustomExceptionMsg( customPrefixPattern )
    call ingo#msg#ErrorMsg(substitute(v:exception, printf('^\C\%%(%s\):\s*', a:customPrefixPattern), '', ''))
endfunction

function! ingo#msg#ShellError( whatFailure, shellOutput )
    if empty(a:shellOutput)
	let l:details = ['exit status ' . v:shell_error]
    else
	let l:details = split(a:shellOutput, "\n")
    endif
    let v:errmsg = printf('Failed to %s: %s', a:whatFailure, join(l:details, ' '))
    echohl ErrorMsg
    echomsg printf('Failed to %s: %s', a:whatFailure, l:details[0])
    for l:moreDetail in l:details[1:]
	echomsg l:moreDetail
    endfor
    echohl None
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
