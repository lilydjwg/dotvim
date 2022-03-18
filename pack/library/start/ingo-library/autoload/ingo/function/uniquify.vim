" ingo/function/uniquify.vim: Functions to ensure uniqueness with function calls.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:records = {}
let s:maxAttempts = {}

function! ingo#function#uniquify#ReturnValue( id, Funcref, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Funcref so often until it returns a value that hasn't been seen (in
"   the scope of a:id) yet.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:id    Identifies the function; uniqueness is ensured in the context of it.
"   a:Funcref   Funcref to be invoked.
"   a:args      Optional arguments to be passed to a:Funcref.
"* RETURN VALUES:
"   Return value of a:Funcref that was never returned before.
"   Throws "ReturnValue: Too many invocations with same return value: N" if all
"   calls return the same value too often.
"******************************************************************************
    if ! has_key(s:records, a:id)
	let s:records[a:id] = {}
    endif

    let l:count = 0
    while l:count < get(s:maxAttempts, a:id, 1000)
	let l:value = call(a:Funcref, a:000)

	let l:v = ingo#compat#DictKey(l:value)
	if ! has_key(s:records[a:id], l:v)
	    let s:records[a:id][l:v] = 1
	    return l:value
	endif

	let l:count += 1
    endwhile

    throw 'ReturnValue: Too many invocations with same return value: ' . l:count
endfunction

function! ingo#function#uniquify#SetMaxAttempts( id, maxAttempts )
"******************************************************************************
"* PURPOSE:
"   Set the maximum number of attempts for ingo#function#uniquify#ReturnValue()
"   calling its a:Funcref in order to obtain a unique value.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:id    Identifies the function; uniqueness is ensured in the context of it.
"   a:maxAttempts   Maximum number of attempts; -1 for no limit.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let s:maxAttempts[a:id] = a:maxAttempts
endfunction

function! ingo#function#uniquify#Clear( id )
"******************************************************************************
"* PURPOSE:
"   Clear the records for a:id that ensure uniqueness.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:id    Identifies the function; uniqueness is ensured in the context of it.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let s:records[a:id] = {}
endfunction

" vikm: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
