" ingo/plugin/cmdcomplete.vim: Functions to build simple command completions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:completeFuncCnt = 0
function! ingo#plugin#cmdcomplete#MakeCompleteFunc( implementation, ... )
"******************************************************************************
"* PURPOSE:
"   Generically define a complete function for :command -complete=customlist
"   with a:implementation as the function body.
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeCompleteFunc(
"   \   'return a:ArgLead ==? "f" ? "Foo" : "Bar"', 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeCompleteFunc(
"	\   'return a:ArgLead ==? "f" ? "Foo" : "Bar"') 'Foo ...'
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:implementation    String representing the function body of the completion
"                       function. It can refer to the completion arguments
"                       a:ArgLead, a:CmdLine, a:CursorPos.
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
    \       a:implementation . "\n" .
    \       'endfunction'

    return l:funcName
endfunction

function! ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc( argumentList, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a static list of possible arguments (for any argument).
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"   \   ['foo', 'fox', 'bar'], 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"	\   ['foo', 'fox', 'bar']) 'Foo ...'
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
    return call('ingo#plugin#cmdcomplete#MakeCompleteFunc',
    \   [printf('return filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', string(a:argumentList))] +
    \   a:000
    \)
endfunction

function! ingo#plugin#cmdcomplete#MakeFirstArgumentFixedListCompleteFunc( argumentList, FurtherArgumentCompletion, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a static list of possible arguments for the first argument only.
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeFirstArgumentFixedListCompleteFunc(
"   \   ['foo', 'fox', 'bar'], 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"	\   ['foo', 'fox', 'bar']) 'Foo ...'
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:argumentList  List of possible first arguments.
"   a:FurtherArgumentCompletion  Funcref for completion of further arguments.
"                                Or List of static completions.
"                                Pass empty String if there should be no further
"                                completion.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    if type(a:FurtherArgumentCompletion) == type([])
	let l:FurtherCompletion = printf('call(%s, [a:ArgLead, a:CmdLine, a:CursorPos])', string(ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(a:FurtherArgumentCompletion)))
    elseif empty(a:FurtherArgumentCompletion)
	let l:FurtherCompletion = '[]'
    else
	let l:FurtherCompletion = printf('call(%s, [a:ArgLead, a:CmdLine, a:CursorPos])', string(a:FurtherArgumentCompletion))
    endif

    return call('ingo#plugin#cmdcomplete#MakeCompleteFunc',
    \   [printf('return (ingo#plugin#cmdcomplete#IsFirstArgument(a:ArgLead, a:CmdLine, a:CursorPos) ? filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'') : %s)', string(a:argumentList), l:FurtherCompletion)] +
    \   a:000
    \)
endfunction

function! s:GetLastCommandArgumentsBeforeCursor( ArgLead, CmdLine, CursorPos ) abort
    let l:cmdlineBeforeCursor = strpart(a:CmdLine, 0, a:CursorPos)
    return get(ingo#cmdargs#command#Parse(l:cmdlineBeforeCursor, '*'), -1, '')
endfunction
function! ingo#plugin#cmdcomplete#IsFirstArgument( ArgLead, CmdLine, CursorPos ) abort
    return (s:GetLastCommandArgumentsBeforeCursor(a:ArgLead, a:CmdLine, a:CursorPos) !~# '^\s*\S\+\s\+')
endfunction
function! ingo#plugin#cmdcomplete#DetermineStageList( ArgLead, CmdLine, CursorPos, firstArgumentList, furtherArgumentMap, defaultFurtherArgumentList ) abort
    let l:lastCommandArgumentsBeforeCursor = s:GetLastCommandArgumentsBeforeCursor(a:ArgLead, a:CmdLine, a:CursorPos)
    if empty(l:lastCommandArgumentsBeforeCursor)
	return a:firstArgumentList
    endif

    for l:firstArgument in a:firstArgumentList
	if l:lastCommandArgumentsBeforeCursor =~# '\V\^\s\*' . escape(l:firstArgument, '\') . '\s\+'
	    return get(a:furtherArgumentMap, l:firstArgument, a:defaultFurtherArgumentList)
	endif
    endfor

    return (l:lastCommandArgumentsBeforeCursor =~# '^\s*\S\+\s\+' ?
    \   a:defaultFurtherArgumentList :
    \   a:firstArgumentList
    \)
endfunction
function! ingo#plugin#cmdcomplete#MakeTwoStageFixedListAndMapCompleteFunc( firstArgumentList, furtherArgumentMap, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   the first argument from a static list of possible arguments and any
"   following arguments from a map keyed by first argument.
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeTwoStageFixedListAndMapCompleteFunc(
"   \   ['foo', 'fox', 'bar'],
"   \   {'foo': ['f1', 'f2'], 'bar': ['b1', 'b2']},
"   \   ['d1', 'd2'],
"   \   'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeTwoStageFixedListAndMapCompleteFunc(
"	\   ['foo', 'fox', 'bar'], {}) 'Foo ...'
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:firstArgumentList     List of possible first arguments.
"   a:furtherArgumentMap    Map of the first actually used argument to the List
"                           of possible second, third, ... arguments.
"   a:defaultFurtherArgumentList    Optional list of further arguments if the
"                                   first argument is not one from
"                                   a:firstArgumentList or there's no such key
"                                   in a:furtherArgumentMap.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    return call('ingo#plugin#cmdcomplete#MakeCompleteFunc',
    \   [printf('return filter(ingo#plugin#cmdcomplete#DetermineStageList(a:ArgLead, a:CmdLine, a:CursorPos, %s, %s, %s), ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', string(a:firstArgumentList), string(a:furtherArgumentMap), string(a:0 ? a:1 : []))] +
    \   a:000[1:]
    \)
endfunction

function! ingo#plugin#cmdcomplete#MakeListExprCompleteFunc( argumentExpr, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a (dynamically invoked) expression (for any argument).
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeListExprCompleteFunc(
"   \   'map(copy(g:values), "v:val[0:3]")', 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"	\   'map(copy(g:values), "v:val[0:3]")') 'Foo ...'
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:argumentExpr  Expression that returns a List of (currently) possible
"		    arguments when evaluated.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    return call('ingo#plugin#cmdcomplete#MakeCompleteFunc',
    \   [printf('return filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', a:argumentExpr)] +
    \   a:000
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
