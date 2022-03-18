" ingo/str/restricted.vim: Functions to restrict arbitrary strings to certain classes.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2014-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.001	28-Feb-2014	file creation

function! ingo#str#restricted#ToShortCharacterwise( expr, ... )
"******************************************************************************
"* PURPOSE:
"   Restrict an arbitrary string a:expr to a short, readable text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Source text.
"   a:default   Text to be used when the source text doesn't fit the
"		requirements of being "short". Defaults to the empty string.
"   a:maxCharacterNum   Maximum width to be considered "short". Defaults to
"			'textwidth' / 80 screen cells.
"* RETURN VALUES:
"   If a:expr is short enough and does not contain multi-line text, return
"   a:expr. Else return nothing / the a:default.
"******************************************************************************
    let l:default = (a:0 ? a:1 : '')
    let l:maxCharacterNum = (a:0 > 1 ? a:2 : (&textwidth > 0 ? &textwidth : 80))

    return (a:expr =~# '\n' || ingo#compat#strchars(a:expr) > l:maxCharacterNum ? l:default : a:expr)
endfunction

function! ingo#str#restricted#ToSafeIdentifier( expr, ...)
"******************************************************************************
"* PURPOSE:
"   Restrict an arbitrary string a:expr to a short one that can be safely used
"   in filenames, URLs, etc. without having to worry about quoting or escaping
"   of special characters.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Source text, or List of strings.
"   a:options.replacementForSpecialCharacters	Replacement character; default "-".
"   a:options.removeFrom    Which position has the lowest priority in case the
"			    result is still too long, and is dropped. One of
"			    "l", "m", "r"; default is "m", dropping from the
"			    middle.
"   a:options.maxCharacterNum   Maximum width. Defaults to 'textwidth' / 80
"				screen cells.
"* RETURN VALUES:
"   Non-alphanumeric characters are replaced by
"   a:options.replacementForSpecialCharacters (two between different List items); those
"   at the front and end are dropped. If the text exceeds a:maxCharacterNum,
"   List elements / alphanumeric sequences from the middle are dropped until it
"   fits.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:repl = get(l:options, 'replacementForSpecialCharacters', '-')
    let l:removeFrom = get(l:options, 'removeFrom', 'm')
    let l:maxCharacterNum = get(l:options, 'maxCharacterNum', &textwidth > 0 ? &textwidth : 80)

    if type(a:expr) == type([])
	let l:source = map(a:expr, 'l:repl . join(split(v:val, "[^[:alnum:]]\\+"), l:repl) . l:repl')
    else
	let l:source = split(a:expr, "[^[:alnum:]]\\+")
    endif

    while ingo#compat#strchars(s:Render(l:source, l:repl)) > l:maxCharacterNum
	if l:removeFrom ==# 'm' && len(l:source) == 2
	    " Special case: take the larger one that still fits.
	    let l:len0 = ingo#compat#strchars(s:Render([l:source[0]], l:repl))
	    let l:len1 = ingo#compat#strchars(s:Render([l:source[1]], l:repl))

	    if l:len0 >= l:len1 && l:len0 <= l:maxCharacterNum
		let l:source = [l:source[0]]
	    elseif l:len1 >= l:len0 && l:len1 <= l:maxCharacterNum
		let l:source = [l:source[1]]
	    else
		let l:source = [l:source[(l:len0 > l:len1 ? 1 : 0)]]
	    endif
	elseif len(l:source) > 1
	    if l:removeFrom ==# 'm'
		let l:dropIdx = len(l:source) / 2
	    elseif l:removeFrom ==# 'l'
		let l:dropIdx = 0
	    elseif l:removeFrom ==# 'r'
		let l:dropIdx = -1
	    else
		throw 'ASSERT: Invalid a:options.removeFrom: ' . string(l:removeFrom)
	    endif
	    call remove(l:source, l:dropIdx)
	elseif stridx(l:source[0], l:repl) != -1
	    " The part can be broken into sub-parts.
	    let l:source = split(l:source[0], '\V\C' . escape(l:repl, '\'))
	else
	    return matchstr(s:Render(l:source, l:repl), '^.\{' . l:maxCharacterNum . '}')
	endif
    endwhile
    return s:Render(l:source, l:repl)
endfunction
function! s:Render( source, repl )
    let l:render = join(a:source, a:repl)
    let l:r = escape(a:repl, '\')
    return substitute(l:render, printf('\V\C\^%s\+\|%s\+\$\|%s\{2}\zs%s\+', l:r, l:r, l:r, l:r), '', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
