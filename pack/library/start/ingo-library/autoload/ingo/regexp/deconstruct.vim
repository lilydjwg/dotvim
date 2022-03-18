" ingo/regexp/deconstruct.vim: Functions for taking apart regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#regexp#deconstruct#RemovePositionAtoms( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove atoms that assert a certain position of the pattern (like ^, $, \<,
"   \%l) from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with position atoms removed.
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#parse#PositionAtomExpr(), '', 'g')
endfunction

function! ingo#regexp#deconstruct#RemoveMultis( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove multi items (*, \+, etc.) that signify the multiplicity of the
"   previous atom from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with multi items removed.
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#parse#MultiExpr(), '', 'g')
endfunction

let s:specialLookup = {
\   'e': "\e",
\   't': "\t",
\   'r': "\r",
\   'b': "\b",
\   'n': "\n",
\}
function! ingo#regexp#deconstruct#UnescapeSpecialCharacters( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove the backslash in front of characters that have special regular
"   expression meaning without it, like [\.*~], and interpret special sequences
"   like \e \t \n.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with special characters turned into literal ones.
"******************************************************************************
    let l:result = a:pattern
    let l:result = substitute(l:result, ingo#regexp#parse#EscapedCharacterExpr(), '\=s:specialLookup[submatch(1)]', 'g')
    let l:result = ingo#escape#Unescape(l:result, '\^$.*~[]')
    return l:result
endfunction

function! ingo#regexp#deconstruct#TranslateSingleCharacterAtoms( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any unspecific single character,
"   i.e. . or \_..
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#parse#SingleCharacterExpr(), "\u2022", 'g')
endfunction

function! ingo#regexp#deconstruct#TranslateCharacterClasses( pattern, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Translate character classes (e.g. \d, \k), collections ([...]; unless they
"   only contain a single literal character), and optionally matched atoms from
"   a:pattern with the passed a:replacements or default ones.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"   a:replacements  Optional Dict that maps each character class / collection to
"                   a replacment.
"* RETURN VALUES:
"   Modified a:pattern with character classes translated.
"******************************************************************************
    let l:pattern = a:pattern
    let l:replacements = (a:0 ? a:1 : {
    \   'blank': ' ',
    \   'return': "\r",
    \   'tab': "\t",
    \   'escape': "\e",
    \   'backspace': "\b",
    \   'cntrl': "\uFF3E",
    \   'punct': "\u203D",
    \   'i': "\U1D456",
    \   'I': "\U1D43C",
    \   'k': "\U1D458",
    \   'K': "\U1D43E",
    \   'f': "\U1D453",
    \   'F': "\U1D439",
    \   'p': "\U1D45D",
    \   'print': "\U1D45D",
    \   'graph': "\U1D45D",
    \   'P': "\U1D443",
    \   'PRINT': "\U1D443",
    \   'GRAPH': "\U1D443",
    \   's': "\U1D460",
    \   'space': "\U1D460",
    \   'S': "\U1D446",
    \   'SPACE': "\U1D446",
    \   'd': "\U1D451",
    \   'digit': "\U1D451",
    \   'D': "\U1D437",
    \   'DIGIT': "\U1D437",
    \   'x': "\U1D465",
    \   'xdigit': "\U1D465",
    \   'X': "\U1D44B",
    \   'XDIGIT': "\U1D44B",
    \   'o': "\U1D45C",
    \   'O': "\U1D442",
    \   'w': "\U1D464",
    \   'W': "\U1D44A",
    \   'h': "\U1D455",
    \   'H': "\U1D43B",
    \   'a': "\U1D44E",
    \   'alpha': "\U1D44E",
    \   'alnum': "\U1D44E",
    \   'A': "\U1D434",
    \   'ALPHA': "\U1D434",
    \   'ALNUM': "\U1D434",
    \   'l': "\U1D459",
    \   'lower': "\U1D459",
    \   'L': "\U1D43F",
    \   'LOWER': "\U1D43F",
    \   'u': "\U1D462",
    \   'upper': "\U1D462",
    \   'U': "\U1D448",
    \   'UPPER': "\U1D448",
    \   '[]': "\u2026",
    \})

    let l:pattern = substitute(l:pattern, '\C' . ingo#regexp#parse#CharacterClassesExpr(), '\=get(l:replacements, submatch(1), "")', 'g')

    " Optional sequence of atoms \%[]. Note: Because these can contain
    " collection-like stuff, it has to be processed before collections.
    let l:pattern = substitute(l:pattern, ingo#regexp#parse#OptionalSequenceExpr(), '\1', 'g')

    let l:pattern = substitute(l:pattern, ingo#regexp#collection#Expr({'isCapture': 1}), '\=s:TransformCollection(l:replacements, submatch(1))', 'g')

    return l:pattern
endfunction
function! s:TransformCollection( replacements, characters ) abort
    let l:literalCharacter = matchstr(a:characters, '^\\\?\zs.$')
    if ! empty(l:literalCharacter)
	return l:literalCharacter
    endif
    let l:characterClass = matchstr(a:characters, '^\[:\zs\a\+\ze:\]$')
    if ! empty(l:characterClass)
	return get(a:replacements, l:characterClass, '')
    endif
    let l:invertedCharacterClass = matchstr(a:characters, '^\^\[:\zs\a\+\ze:\]$')
    if ! empty(l:invertedCharacterClass)
	return get(a:replacements, toupper(l:invertedCharacterClass), '')
    endif

    return get(a:replacements, '[]', '')
endfunction
function! ingo#regexp#deconstruct#RemoveCharacterClasses( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Remove character classes (e.g. \d, \k), collections ([...]; unless they only
"   contain a single literal character), and optionally matched atoms from
"   a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with character classes removed.
"******************************************************************************
    return ingo#regexp#deconstruct#TranslateCharacterClasses(a:pattern, {})
endfunction

function! ingo#regexp#deconstruct#TranslateNumberEscapes( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Convert characters escaped as numbers from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with numbered escapes translated to literal characters.
"******************************************************************************
    let l:pattern = a:pattern

    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%d\(\d\+\)', '\=nr2char(str2nr(submatch(1)))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%o\(\o\+\)', '\=nr2char(str2nr(submatch(1), 8))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%x\(\x\{1,2}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%u\(\x\{1,4}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%U\(\x\{1,8}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')

    return l:pattern
endfunction

function! ingo#regexp#deconstruct#TranslateBranches( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Translate regular expression branches (/\(foo\|bar\)/) inside a:pattern into
"   simpler notation (foo|bar).
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with branches translated.
"******************************************************************************
    let l:pattern = a:pattern

    for [l:search, l:replace] in [['%\?(', '('], ['|', '|'], [')', ')']]
	let l:pattern = substitute(l:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\' . l:search, l:replace, 'g')
    endfor

    return l:pattern
endfunction

function! ingo#regexp#deconstruct#RemoveOtherAtoms( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Remove any non-ordinary (i.e. not a literal or escaped character) atom that
"   isn't already removed or translated by one of the other functions here.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#parse#OtherAtomExpr(), '', 'g')
endfunction

function! ingo#regexp#deconstruct#ToQuasiLiteral( pattern )
"******************************************************************************
"* PURPOSE:
"   Turn a:pattern into something resembling a literal match of it by removing
"   any non-ordinary atoms, multis, translating character classes / collections
"   and branches, and unescaping.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern that resembles a literal match.
"******************************************************************************
    let l:result = a:pattern
    let l:result = ingo#regexp#deconstruct#RemoveOtherAtoms(l:result)
    let l:result = ingo#regexp#deconstruct#RemovePositionAtoms(l:result)
    let l:result = ingo#regexp#deconstruct#RemoveMultis(l:result)
    let l:result = ingo#regexp#deconstruct#TranslateSingleCharacterAtoms(l:result)
    let l:result = ingo#regexp#deconstruct#TranslateCharacterClasses(l:result)
    let l:result = ingo#regexp#deconstruct#TranslateNumberEscapes(l:result)
    let l:result = ingo#regexp#deconstruct#TranslateBranches(l:result)

    " Do the unescaping last.
    let l:result = ingo#regexp#deconstruct#UnescapeSpecialCharacters(l:result)
    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
