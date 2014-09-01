" ingo/plugin/setting.vim: Functions for retrieving plugin settings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.005	16-Apr-2014	Add ingo#plugin#setting#BooleanToStringValue().
"   1.010.004	08-Jul-2013	Add prefix to exception thrown from
"				ingo#plugin#setting#GetFromScope().
"   1.005.003	10-Apr-2013	Move into ingo-library.
"	002	06-Jul-2010	ENH: Now supporting passing of default value
"				instead of throwing exception, like the built-in
"				get().
"	001	04-Sep-2009	file creation

function! ingo#plugin#setting#GetFromScope( variableName, scopeList, ... )
"******************************************************************************
"* PURPOSE:
"   Get a configuration variable that can be defined in multiple scopes.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:variableName  Name of the variable.
"   a:scopeList     List of variable scope prefixes. These are tried in
"		    sequential order.
"   a:defaultValue  Optional value to be returned when no a:variableName is
"		    defined in any of the a:scopeList. If omitted, an exception
"		    is thrown instead.
"* RETURN VALUES:
"   Value of a:variableName from the first scope in a:scopeList where it is
"   defined, or a:defaultValue, or exception.
"******************************************************************************
    for l:scope in a:scopeList
	let l:variable = l:scope . ':' . a:variableName
	if exists( l:variable )
	    execute 'return' l:variable
	endif
    endfor
    if a:0
	return a:1
    else
	throw 'GetFromScope: No variable named "' . a:variableName . '" defined.'
    endif
endfunction

function! ingo#plugin#setting#GetBufferLocal( variableName, ... )
    return call('ingo#plugin#setting#GetFromScope', [a:variableName, ['b', 'g']] + a:000)
endfunction
function! ingo#plugin#setting#GetWindowLocal( variableName, ... )
    return call('ingo#plugin#setting#GetFromScope', [a:variableName, ['w', 'g']] + a:000)
endfunction

function! ingo#plugin#setting#BooleanToStringValue( settingName, ... )
    if a:0
	let l:settingValue = a:1
    else
	execute 'let l:settingValue = &' . a:settingName
    endif
    return l:settingValue ? a:settingName : 'no' . a:settingName
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
