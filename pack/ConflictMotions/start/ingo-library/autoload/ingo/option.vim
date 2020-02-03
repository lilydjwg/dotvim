" ingo/option.vim: Functions for dealing with Vim options.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#option#Split( optionValue, ... )
    return call('split', [a:optionValue, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!,'] + a:000)
endfunction
function! ingo#option#SplitAndUnescape( optionValue, ... )
    return map(call('ingo#option#Split', [a:optionValue] + a:000), 'ingo#escape#Unescape(v:val, ",\\")')
endfunction

function! ingo#option#Contains( optionValue, expr )
    return (index(ingo#option#SplitAndUnescape(a:optionValue), a:expr) != -1)
endfunction
function! ingo#option#ContainsOneOf( optionValue, list )
    let l:optionValues = ingo#option#SplitAndUnescape(a:optionValue)
    for l:expr in a:list
	if (index(l:optionValues, l:expr) != -1)
	    return 1
	endif
    endfor
    return 0
endfunction

function! ingo#option#JoinEscaped( ... )
    return join(a:000, ',')
endfunction
function! ingo#option#JoinUnescaped( ... )
    return join(map(copy(a:000), 'escape(v:val, ",")'), ',')
endfunction

function! ingo#option#Append( val1, ... )
"******************************************************************************
"* PURPOSE:
"   Add a:val2, a:val3, ... to the original a:val1 option value. Commas in the
"   additional values will be escaped, empty values will be skipped.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:val1  Original option value.
"* RETURN VALUES:
"   Concatenation of a:val1, a:val2, ...
"******************************************************************************
    let l:result = a:val1
    for l:val in map(copy(a:000), 'escape(v:val, ",")')
	if empty(l:result)
	    let l:result = l:val
	elseif ! empty(l:val)
	    let l:result .= ',' . l:val
	endif
    endfor
    return l:result
endfunction
function! ingo#option#Prepend( val1, ... )
"******************************************************************************
"* PURPOSE:
"   Prepend a:val2, a:val3, ... to the original a:val1 option value. Commas in
"   the additional values will be escaped, empty values will be skipped.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:val1  Original option value.
"* RETURN VALUES:
"   Concatenation of a:val2, ..., a:val1
"******************************************************************************
    let l:result = []
    for l:val in map(copy(a:000), 'escape(v:val, ",")') + [a:val1]
	if empty(l:result)
	    let l:result = l:val
	elseif ! empty(l:val)
	    let l:result .= ',' . l:val
	endif
    endfor
    return l:result
endfunction

function! ingo#option#GetBinaryOptionValue( optionName )
    execute 'let l:originalOptionValue = &' . a:optionName
    return (l:originalOptionValue ? '' : 'no') . a:optionName
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
