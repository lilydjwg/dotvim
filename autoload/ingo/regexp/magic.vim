" ingo/regexp/magic.vim: Functions around handling magicness in regular expressions.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script for ingo#regexp#magic#Normalize()
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.002	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.006.001	24-May-2013	file creation from ingosearch.vim.

function! ingo#regexp#magic#GetNormalizeMagicnessAtom( pattern )
"******************************************************************************
"* PURPOSE:
"   Return normalizing \m (or \M) if a:pattern contains atom(s) that change the
"   default magicness. This makes it possible to append another pattern without
"   having a:pattern affect it.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern	Regular expression to observe.
"* RETURN VALUES:
"   Normalizing atom or empty string.
"******************************************************************************
    let l:normalizingAtom = (&magic ? 'm' : 'M')
    let l:magicChangeAtoms = substitute('vmMV', '\C'.l:normalizingAtom, '', '')

    return (a:pattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[' . l:magicChangeAtoms . ']' ? '\' . l:normalizingAtom : '')
endfunction

let s:magicAtomsExpr = '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[vmMV]'
function! ingo#regexp#magic#HasMagicAtoms( pattern )
    return a:pattern =~# s:magicAtomsExpr
endfunction
let s:specialSearchCharacterExpressions = {
\   'v': '\W',
\   'm': '[\\^$.*[~]',
\   'M': '[\\^$]',
\   'V': '\\',
\}
function! s:ConvertMagicness( pattern, sourceSpecialCharacterExpr, targetSpecialCharacterExpr )
    let l:isEscaped = 0
    let l:chars = split(a:pattern, '\zs')
    for l:index in range(len(l:chars))
	let l:char = l:chars[l:index]

	if (l:char =~# a:sourceSpecialCharacterExpr) + (l:char =~# a:targetSpecialCharacterExpr) == 1
	    " The current character belongs to different classes in source and target.
	    if l:isEscaped
		let l:chars[l:index - 1] = ''
	    else
		let l:chars[l:index] = '\' . l:char
	    endif
	endif

	if l:char ==# '\'
	    let l:isEscaped = ! l:isEscaped
	else
	    let l:isEscaped = 0
	endif
    endfor

    return join(l:chars, '')
endfunction
function! ingo#regexp#magic#Normalize( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove any \v, /m, \M, \V atoms from a:pattern that change the magicness,
"   and re-write the pattern (by selective escaping and unescaping) into an
"   equivalent pattern that is based on the current 'magic' setting.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern	Regular expression that may contain atoms that affect the
"		magicness.
"* RETURN VALUES:
"   Equivalent pattern that has any atoms affecting the magicness removed and is
"   based on the current 'magic' setting.
"******************************************************************************
    let l:currentMagicMode = (&magic ? 'm' : 'M')
    let l:defaultMagicMode = l:currentMagicMode
    let l:patternFragments = ingo#collections#SplitKeepSeparators(a:pattern, s:magicAtomsExpr, 1)
    " Because we asked to keep any empty fragments, we can easily test whether
    " there's any work to do.
    if len(l:patternFragments) == 1
	return a:pattern
    endif
"****D echomsg string(l:patternFragments)
    for l:fragmentIndex in range(len(l:patternFragments))
	let l:fragment = l:patternFragments[l:fragmentIndex]
	if l:fragment =~# s:magicAtomsExpr
	    let l:currentMagicMode = l:fragment[1]
	    let l:patternFragments[l:fragmentIndex] = ''
	    continue
	endif

	if l:currentMagicMode ==# l:defaultMagicMode
	    " No need for conversion.
	    continue
	endif

	let l:patternFragments[l:fragmentIndex] = s:ConvertMagicness(
	\   l:fragment,
	\   s:specialSearchCharacterExpressions[l:currentMagicMode],
	\   s:specialSearchCharacterExpressions[l:defaultMagicMode]
	\)
    endfor
"****D echomsg string(l:patternFragments)
    return join(l:patternFragments, '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
