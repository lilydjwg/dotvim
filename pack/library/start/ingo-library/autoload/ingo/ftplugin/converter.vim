" ingo/ftplugin/converter.vim: Supporting functions to build a file converter.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:GetName( commandDefinition )
    return (has_key(a:commandDefinition, 'name') ? a:commandDefinition.name : fnamemodify(a:commandDefinition.command, ':t'))
endfunction
function! ingo#ftplugin#converter#GetNames( commandDefinitions )
    return map(copy(a:commandDefinitions), "s:GetName(v:val)")
endfunction
function! ingo#ftplugin#converter#GetArgumentMaps( commandDefinitions )
    return ingo#dict#FromItems(map(copy(a:commandDefinitions), "[v:val.name, get(v:val, 'arguments', [])]"))
endfunction

function! ingo#ftplugin#converter#GetCommandDefinition( commandDefinitionsVariable, arguments )
    execute 'let l:commandDefinitions =' a:commandDefinitionsVariable

    if empty(l:commandDefinitions)
	throw printf('converter: No converters are configured in %s.', a:commandDefinitionsVariable)
    elseif empty(a:arguments)
	if len(l:commandDefinitions) > 1
	    throw 'converter: Multiple converters are available; choose one: ' . join(ingo#ftplugin#converter#GetNames(l:commandDefinitions), ', ')
	endif

	let l:command = l:commandDefinitions[0]
	let l:commandArguments = ''
    else
	let l:parse = matchlist(a:arguments, '^\(\S\+\)\s\+\(.*\)$')
	let [l:selectedName, l:commandArguments] = (empty(l:parse) ? [a:arguments, ''] : l:parse[1:2])

	let l:command = get(filter(copy(l:commandDefinitions), 'l:selectedName == s:GetName(v:val)'), 0, '')
	if empty(l:command)
	    if len(l:commandDefinitions) > 1
		throw printf('converter: No such converter: %s', l:selectedName)
	    else
		" With a single default command, these are just custom command
		" arguments passed through.
		let l:command = l:commandDefinitions[0]
		let l:commandArguments = a:arguments
	    endif
	endif
    endif

    return [l:command, l:commandArguments]
endfunction

function! s:Action( actionName, commandDefinition ) abort
    let l:Action = get(a:commandDefinition, a:actionName, '')
    if ! empty(l:Action)
	call ingo#actions#ExecuteOrFunc(l:Action)
    endif
endfunction
function! ingo#ftplugin#converter#PreAction( commandDefinition ) abort
    call s:Action('preAction', a:commandDefinition)
endfunction
function! ingo#ftplugin#converter#PostAction( commandDefinition ) abort
    call s:Action('postAction', a:commandDefinition)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
