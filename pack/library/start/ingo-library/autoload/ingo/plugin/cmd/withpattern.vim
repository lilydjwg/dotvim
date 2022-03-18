" ingo/plugin/cmd/withpattern.vim: Functions to make plugin commands that operate on a pattern.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:lastCommandPatternForId = {}

function! ingo#plugin#cmd#withpattern#CommandWithPattern( id, isQuery, isSelection, CommandTemplate, ... )
"******************************************************************************
"* PURPOSE:
"   Build a command from a:CommandTemplate that is passed a queried / recalled
"   pattern (stored under a:id) and apply this to the visual selection or the
"   command-line range created from a:count, defaulting to the current line if
"   no count is given.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - queries for input with a:isQuery
"   - executes a:CommandTemplate
"* INPUTS:
"   a:id    Identifier under which the queried pattern is stored and recalled.
"   a:isQuery   Flag whether the pattern is queried from the user.
"   a:isSelection   Flag whether the command should be applied to the last
"                   selected range.
"   a:CommandTemplate   Ex command that contains a %s for the queried / recalled
"                       pattern to be inserted. Or Funcref that takes a single
"                       argument and is :call'ed on the range.
"   a:defaultRange  Optional default range when count is 0. Defaults to the
"                   current line ("."); pass "%" to default to the whole buffer
"                   if no count is given (even though the command defaults to
"                   the current line).
"   a:count         Optional given count.
"* RETURN VALUES:
"   1 if success, 0 if the execution failed. An error message is then available
"   from ingo#err#Get().
"******************************************************************************
    if a:isQuery
	let l:pattern = input('/')
	if empty(l:pattern) | return 1 | endif
	let s:lastCommandPatternForId[a:id] = l:pattern
    endif
    if ! has_key(s:lastCommandPatternForId, a:id)
	call ingo#err#Set('No pattern defined yet')
	return 0
    endif

    if type(a:CommandTemplate) == type(function('tr'))
	let l:command = printf('call %s(%s)', a:CommandTemplate, string(s:lastCommandPatternForId[a:id]))
    else
	let l:command = printf(a:CommandTemplate, escape(s:lastCommandPatternForId[a:id], '/'))
    endif

    try
	execute (a:isSelection ? "'<,'>" : call('ingo#cmdrange#FromCount', a:000)) . l:command
	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
