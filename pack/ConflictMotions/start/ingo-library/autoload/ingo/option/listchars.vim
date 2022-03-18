" ingo/option/listchars.vim: Functions around the listchars option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#option#listchars#GetValues() abort
"******************************************************************************
"* PURPOSE:
"   Get a Dictionary mapping 'listchars' settings to their character(s) values.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Dict with defined 'listchars' settings as keys and their character(s) as
"   values.
"******************************************************************************
    let l:elements = split(&listchars, ',') " No need to escape, according to :help 'listchars', "The characters ':' and ',' should not be used."
    let l:elementDict = ingo#dict#FromItems(map(l:elements, 'split(v:val, ":")'))
    return l:elementDict
endfunction

function! ingo#option#listchars#GetValue( element ) abort
"******************************************************************************
"* PURPOSE:
"   Get the character(s) used for showing the a:element setting of 'listchars'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:element   Setting name of 'listchars', e.g. "tab".
"* RETURN VALUES:
"   Character(s) extracted from 'listchars', or empty String.
"******************************************************************************
    return get(ingo#option#listchars#GetValues(), a:element, '')
endfunction

function! ingo#option#listchars#Render( text, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Render a:text by replacing any special characters with the settings from
"   'listchars', as if :set list were on.
"* LIMITATION:
"   Tabs are rendered with a fixed width (of the current 'tabstop' value, as if
"   at the beginning of the line), not according to position!
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text              Input text to be rendered.
"   a:options.isTextAtStart
"                       Flag whether the "lead" setting should be rendered. Off
"                       by default.
"   a:options.isTextAtEnd
"                       Flag whether the "eol" and "trail" settings should be
"                       rendered. Off by default.
"   a:options.listchars Dict with defined 'listchars' settings as keys and their
"                       character(s) as values, to take instead of the
"                       'listchars' values.
"   a:options.fallback  Dict with defined 'listchars' settings as keys and their
"                       character(s) as values, to take when 'listchars' /
"                       a:options.listchars does not contain such key. No
"                       further processing will be done on those.
"   a:options.tabWidth  Width of a tab character for rendering.
"* RETURN VALUES:
"   a:text with special characters replaced.
"******************************************************************************
    if a:0 == 0
	let l:isTextAtEnd = 0
	let l:options = {}
    elseif a:0 == 1 && type(a:1) == type({})
	let l:options = a:1
	let l:isTextAtEnd = get(l:options, 'isTextAtEnd', 0)
    else    " Deprecated: a:isTextAtEnd argument
	let l:isTextAtEnd = a:1
	let l:options = (a:0 >= 2 ? a:2 : {})
    endif
    let l:listcharValues = get(l:options, 'listchars', ingo#option#listchars#GetValues())
    let l:fallbackValues = get(l:options, 'fallback', {})
    let l:isTextAtStart = get(l:options, 'isTextAtStart', 0)
    if has_key(l:listcharValues, 'tab')
	let l:tabWidth = get(l:options, 'tabWidth', &tabstop)
	let l:thirdTabValue = matchstr(l:listcharValues.tab, '^..\zs.')
	let l:listcharValues.tab = (empty(l:thirdTabValue) || l:tabWidth > 1 ? matchstr(l:listcharValues.tab, '^.') : '') .
	\   repeat(matchstr(l:listcharValues.tab, '^.\zs.'), l:tabWidth - 1 - (! empty(l:thirdTabValue))) .
	\   l:thirdTabValue
    endif

    let l:text = a:text

    for [l:setting, l:pattern] in [
    \   ['tab', '\t'],
    \   ['nbsp', '\%xa0\|\%u202f']
    \] + (l:isTextAtEnd ? [
    \       ['trail', ' \( *$\)\@='],
    \       ['eol', '$']
    \   ] : []
    \) + (l:isTextAtStart ? [
    \       ['lead', '\(^ *\)\@<= '],
    \   ] : []
    \) +
    \   [['space', ' ']]
	if has_key(l:listcharValues, l:setting)
	    let l:replacement = l:listcharValues[l:setting]
	elseif has_key(l:fallbackValues, l:setting)
	    let l:replacement = l:fallbackValues[l:setting]
	else
	    continue
	endif
	let l:text = substitute(l:text, l:pattern, escape(l:replacement, '\&'), 'g')
    endfor

    return l:text
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
