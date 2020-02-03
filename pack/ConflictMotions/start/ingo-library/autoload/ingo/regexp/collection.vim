" ingo/regexp/collection.vim: Functions around handling collections in regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#regexp#collection#Expr( ... )
"******************************************************************************
"* PURPOSE:
"   Returns a regular expression that matches any collection atom.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   The exact pattern can be influenced by the following options:
"   a:option.isBarePattern          Flag whether to return a bare pattern that
"                                   does not make any assertions on what's
"                                   before the [. This overrides the following
"                                   options. Default false.
"   a:option.isIncludeEolVariant    Flag whether to include the /\_[]/ variant as
"                                   well. Default true.
"   a:option.isMagic                Flag whether 'magic' is set, and [] is used
"                                   instead of \[]. Default true.
"   a:option.isCapture              Flag whether to capture the stuff inside the
"                                   collection. Default false.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBarePattern = get(l:options, 'isBarePattern', 0)
    let l:isIncludeEolVariant = get(l:options, 'isIncludeEolVariant', 1)
    let l:isMagic = get(l:options, 'isMagic', 1)
    let l:isCapture = get(l:options, 'isCapture', 0)
    let [l:capturePrefix, l:captureSuffix] = (l:isCapture ? ['\(', '\)'] : ['', ''])

    let l:prefixExpr = (l:isBarePattern ?
    \   '' :
    \   '\%(\%(^\|[^\\]\)\%(\\\\\)*\\%\?\)\@<!' . (l:isMagic ?
    \       (l:isIncludeEolVariant ? '\%(\\_\)\?' : '') :
    \       (l:isIncludeEolVariant ? '\\_\?' : '\\')
    \   )
    \)

    return l:prefixExpr . '\[' . l:capturePrefix . '\%(\]$\)\@!\]\?\%(\[:\a\+:\]\|\[=.\{-}=\]\|\[\..\.\]\|[^\]]\)*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . l:captureSuffix . '\]'
endfunction

function! ingo#regexp#collection#GetSpecialCharacters()
    return '[]-^\'
endfunction

function! ingo#regexp#collection#EscapeLiteralCharacters( text )
    " XXX: If we escape [ as \[, all backslashes will be matched, too.
    " Instead, we have to place [ last in the collection: [abc[].
    if a:text =~# '\['
	return escape(substitute(a:text, '\[', '', 'g'), ingo#regexp#collection#GetSpecialCharacters()) . '['
    else
	return escape(a:text, ingo#regexp#collection#GetSpecialCharacters())
    endif
endfunction

function! ingo#regexp#collection#LiteralToRegexp( text, ... )
    let l:isInvert = (a:0 && a:1)
    return '[' . (l:isInvert ? '^' : '') . ingo#regexp#collection#EscapeLiteralCharacters(a:text) . ']'
endfunction

function! ingo#regexp#collection#ToBranches( pattern )
"******************************************************************************
"* PURPOSE:
"   Convert each collection in a:pattern into an equivalent group of alternative
"   branches (where possible; i.e. for single characters). For example:
"   /[abc[:digit:]]/ to /\%(a\|b\|c\|[[:digit:]]\)/. Does not support negative
"   collections /[^...]/. Things that cannot be (easily) represented is kept as
"   smaller collections in a branch, e.g. /[a-fxyz]/ to
"   /\%([a-f]\|x\|y\|z\)/.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression, usually with collection(s) in them
"* RETURN VALUES:
"   Modified a:pattern
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#collection#Expr(), '\=s:CollectionToBranches(submatch(0))', 'g')
endfunction
function! s:CollectionToBranches( collection )
    if a:collection =~# '^\[\^'
	return a:collection " Negative collections not yet supported.
    endif

    let l:branches = map(
    \   ingo#collections#SplitIntoMatches(matchstr(a:collection, '^\[\zs.*\ze\]$'), '[^-]-[^-]\|\[:\a\+:\]\|\[=.\{-}]\]\|\[\..\.\]\|\\[etrbn]\|\\d\d\+\|\\[uU]\x\{4,8\}\|.'),
    \   's:CollectionElementToPattern(v:val)'
    \)
    return '\%(' . join(l:branches, '\|') . '\)'
endfunction
function! s:CollectionElementToPattern( collectionElement )
    if a:collectionElement =~# '^\%(\\[etrbn]\|.\)$'
	" We can return (escaped) single characters as-is.
	return a:collectionElement
    else
	" For the rest, enclose in a (smaller) collection on its own.
	return '[' . a:collectionElement . ']'
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
