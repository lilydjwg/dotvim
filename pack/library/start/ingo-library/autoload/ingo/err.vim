" ingo/err.vim: Functions for proper Vim error handling with :echoerr.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.006	23-May-2017	Add ingo#err#Command() for an alternative way of
"				passing back [error] commands to be executed.
"   1.029.005	17-Dec-2016	Add ingo#err#SetAndBeep().
"   1.028.004	18-Nov-2016	ENH: Add optional {context} to all ingo#err#...
"				functions, in case other custom commands can be
"				called between error setting and checking, to
"				avoid clobbering of your error message.
"   1.009.003	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.005.002	17-Apr-2013	Add ingo#err#IsSet() for those cases when
"				wrapping the command in :if does not work (e.g.
"				:call'ing a range function).
"   1.002.001	08-Mar-2013	file creation

"******************************************************************************
"* PURPOSE:
"   Custom commands should use :echoerr for error reporting, because that also
"   properly aborts a command sequence. The echoing via ingo#msg#ErrorMsg() does
"   not provide this and is therefore deprecated (though sufficient for most
"   purposes).
"   This set of functions solves the problem that the error is often raised in a
"   function, but the :echoerr has to be done directly from the :command (to
"   avoid the printing of the multi-line error source). Unfortunately, an error
"   is still raised when an empty expression is used. One could return the error
"   string from the function and then perform the :echoerr on non-empty result,
"   but that requires a temporary (global) variable and is cumbersome.
"* USAGE:
"   Inside your function, invoke one of the ingo#err#Set...() functions.
"   Indicate to the invoking :command via a boolean flag whether the command
"   succeeded. On failure, :echoerr the stored error message via ingo#err#Get().
"	command! Foo if ! Foo#Bar() | echoerr ingo#err#Get() | endif
"   If you cannot wrap the function in :if, you have to ingo#err#Clear() the
"   message inside your function, and invoke like this:
"	function! Foo#Bar() range
"	    call ingo#err#Clear()
"	    ...
"	endfunction
"	nnoremap <Leader>f :call Foo#Bar()<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"   Don't invoke anything after the :echoerr ... | endif | XXX! Though this is
"   normally executed, when run inside try...catch, it isn't! Better place the
"   command(s) between your function and the :echoerr, and also query
"   ingo#err#IsSet() to avoid having to use a temporary variable to get the
"   returned error flag across the command(s).
"   If there's a chance that other custom commands (that may also use these
"   error functions) are invoked between your error setting and checking (also
"   maybe triggered by autocmds), you can pass an optional {context} (e.g. your
"   plugin / command name) to any of the commands.
"   Note: With this approach, further typed commands will be aborted in a macro
"   / mapping. However, further commands in a command sequence or function (even
"   with :function-abort) will still be executed, unlike built-in commands (e.g.
"   :substitute/doesNotExist//). To prevent execution of further commands, you
"   have to wrap everything in try...catch (which is recommended anyhow, because
"   a function abort will still print a ugly multi-line exception, not a short
"   user-friendly message).
"******************************************************************************
let s:err = {}
let s:errmsg = ''
function! ingo#err#Get( ... )
    return (a:0 ? get(s:err, a:1, '') : s:errmsg)
endfunction
function! ingo#err#Clear( ... )
    if a:0
	let s:err[a:1] = ''
    else
	let s:errmsg = ''
    endif
endfunction
function! ingo#err#IsSet( ... )
    return ! empty(a:0 ? get(s:err, a:1, '') : s:errmsg)
endfunction
function! ingo#err#Set( errmsg, ... )
    if a:0
	let s:err[a:1] = a:errmsg
    else
	let s:errmsg = a:errmsg
    endif
endfunction
function! ingo#err#SetVimException( ... )
    call call('ingo#err#Set', [ingo#msg#MsgFromVimException()] + a:000)
endfunction
function! ingo#err#SetCustomException( customPrefixPattern, ... )
    call call('ingo#err#Set', [substitute(v:exception, printf('^\C\%%(%s\):\s*', a:customPrefixPattern), '', '')] + a:000)
endfunction
function! ingo#err#SetAndBeep( text )
    call ingo#err#Set(a:text)
    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
endfunction


"******************************************************************************
"* PURPOSE:
"   Sometimes you cannot return the status, but need to directly return the set
"   of commands to execute, or alternatively the error command. This function
"   allows you to assemble such.
"* USAGE:
"	command! Foo execute Foo#Bar()
"	function! Foo#Bar()
"	    if (error)
"		return ingo#err#Command('This did not work')
"	    else
"		return 'echomsg "yay, okay"'
"	    endif
"	endfunction
"******************************************************************************
function! ingo#err#Command( errmsg )
    return 'echoerr ' . string(a:errmsg)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
