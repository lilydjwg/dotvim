" ingo/plugin/persistence.vim: Functions to store plugin data persistently across Vim sessions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:compatFor = (exists('g:IngoLibrary_CompatFor') ? ingo#collections#ToDict(split(g:IngoLibrary_CompatFor, ',')) : {})

function! s:CompatibilityDeserialization( globalVariableName, targetType, rawValue )
    if (a:targetType == type([]) || a:targetType == type({})) && type(a:rawValue) != a:targetType
	try
	    execute 'let l:tempValue = ' a:rawValue

	    if type(l:tempValue) == a:targetType
		return l:tempValue
	    else
		throw printf('Load: Wrong deserialized type in %s; expected %d got %d.', a:globalVariableName, a:targetType, type(l:tempValue))
	    endif
	catch /^Vim\%((\a\+)\)\=:/
	    throw 'Load: Corrupted deserialized value in ' . a:globalVariableName
	endtry
    else
	return a:rawValue
    endif
endfunction
if (v:version == 703 && has('patch030') || v:version > 703) && ! has_key(s:compatFor, 'viminfoBasicTypes')
    function! s:CompatibilitySerialization( rawValue )
	return a:rawValue
    endfunction
else
    function! s:CompatibilitySerialization( rawValue )
	return string(a:rawValue)
    endfunction
endif

function! ingo#plugin#persistence#CanPersist( ... )
    return (index(split(&viminfo, ','), '!') != -1) && (! a:0 || a:1 =~# '^\u\L*$')
endfunction

function! ingo#plugin#persistence#Store( variableName, value )
"******************************************************************************
"* PURPOSE:
"   Store a:value under a:variableName. If empty(a:value), removes
"   a:variableName.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines / updates global a:variableName.
"* INPUTS:
"   a:variableName  Global variable under which a:value is to be stored, if
"                   uppercased and configured, also in the viminfo file.
"   a:value         Value to be stored.
"* RETURN VALUES:
"   1 if persisted (/ removed) successfully, 0 if persistence is not configured,
"   or the variable is not all-uppercase.
"******************************************************************************
    let l:globalVariableName = 'g:' . a:variableName

    if empty(a:value)
	execute 'unlet!' l:globalVariableName
    else
	execute 'let' l:globalVariableName '= s:CompatibilitySerialization(a:value)'
    endif

    return ingo#plugin#persistence#CanPersist(a:variableName)
endfunction

function! ingo#plugin#persistence#Add( variableName, ... )
"******************************************************************************
"* PURPOSE:
"   Add a:value / a:key + a:value in the List / Dict a:variableName.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines / updates global a:variableName.
"* INPUTS:
"   a:variableName  Global variable under which a:value is to be stored, if
"                   uppercased and configured, also in the viminfo file.
"   a:key           Optional key under which a:value is stored in a Dict-type
"                   a:variableName.
"   a:value         Value to be stored.
"* RETURN VALUES:
"   1 if persisted successfully, 0 if persistence is not configured, or the
"   variable is not all-uppercase.
"   Throws "Add: Wrong variable type" if a:variableName is already defined by
"   does not have the correct type for the number of arguments passed.
"******************************************************************************
    if a:0 < 1 || a:0 > 2
	throw "Add: Must pass [key, ] value"
    endif
    let l:isList = (a:0 == 1)

    let l:globalVariableName = 'g:' . a:variableName

    if exists(l:globalVariableName)
	let l:original = ingo#plugin#persistence#Load(a:variableName)
	if type(l:original) != type(l:isList ? [] : {})
	    throw "Add: Wrong variable type"
	endif
    else
	let l:original = (l:isList ? [] : {})
    endif

    if l:isList
	call add(l:original, a:1)
    else
	let l:original[a:1] = a:2
    endif

    return ingo#plugin#persistence#Store(a:variableName, l:original)
endfunction

function! ingo#plugin#persistence#Remove( variableName, expr )
"******************************************************************************
"* PURPOSE:
"   Remove a:expr (representing an index / key) from the List / Dict
"   a:variableName.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Updates global a:variableName.
"* INPUTS:
"   a:variableName  Global variable under which a:value is to be stored, if
"                   uppercased and configured, also in the viminfo file.
"   a:expr          List index / Dictionary key to be removed.
"* RETURN VALUES:
"   1 if persisted successfully, 0 if persistence is not configured, or the
"   variable is not all-uppercase.
"******************************************************************************
    let l:globalVariableName = 'g:' . a:variableName

    if exists(l:globalVariableName)
	let l:original = ingo#plugin#persistence#Load(a:variableName)

	if type(l:original) == type([])
	    call remove(l:original, a:expr)
	elseif type(l:original) == type({})
	    unlet! l:original[a:expr]
	else
	    throw 'Remove: Not list nor dict'
	endif

	return ingo#plugin#persistence#Store(a:variableName, l:original)
    else
	" Nothing to do.
	return ingo#plugin#persistence#CanPersist(a:variableName)
    endif

endfunction

function! ingo#plugin#persistence#Load( variableName, ... )
"******************************************************************************
"* PURPOSE:
"   Load the persisted a:variableName and return it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:variableName  Global variable that (if uppercased) is stored in viminfo
"                   file.
"   a:defaultValue  Optional value to return when persistence is not configured,
"                   or nothing was stored yet in viminfo. If omitted, will throw
"                   a Load: .. exception instead.
"                   For older Vim versions, also indicates the variable type
"                   (List or Dict) into which the raw value is deserialized.
"* RETURN VALUES:
"   Persisted (or current if a:variableName contains lowercase characters) value
"   or a:defaultValue / exception.
"   Throws "Load: Corrupted deserialized value in ..." or "Load: Wrong
"   deserialized type ..." if a:defaultValue is given and the deserialization to
"   its variable type fails.
"******************************************************************************
    let l:globalVariableName = 'g:' . a:variableName
    if exists(l:globalVariableName)
	let l:rawValue = eval(l:globalVariableName)
	return (a:0 ? s:CompatibilityDeserialization(l:globalVariableName, type(a:1), l:rawValue) : l:rawValue)
    elseif a:0
	return a:1
    else
	throw printf('Load: Nothing stored under %s%s', l:globalVariableName, (ingo#plugin#persistence#CanPersist(a:variableName) ? '' : ', and persistence not ' . (ingo#plugin#persistence#CanPersist() ? 'possible for that name' : 'configured')))
    endif
endfunction

function! ingo#plugin#persistence#QueryYesNo( question )
"******************************************************************************
"* PURPOSE:
"   Ask the user whether a:question should be accepted or declined, with
"   variants for the current instance, the current Vim session, or persistently
"   across sessions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Queries user via confirm().
"* INPUTS:
"   a:question  Text to be shown to the user.
"* RETURN VALUES:
"   One of "Yes", "No", "Always", "Never", "Forever", "Never ever", or empty
"   string if the dialog was aborted.
"******************************************************************************
    let l:choices = ['&Yes', '&No', '&Always', 'Ne&ver' ]
    if ingo#plugin#persistence#CanPersist()
	let l:choices += ['&Forever', 'Never &ever']
    endif

    return ingo#query#ConfirmAsText(a:question, l:choices, 0, 'Question')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
