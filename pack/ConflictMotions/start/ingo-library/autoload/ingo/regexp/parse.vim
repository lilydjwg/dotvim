" ingo/regexp/parse.vim: Functions around parsing patterns.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#parse#MultiExpr()
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any multi.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\*\|\\[+=?]\|\\{-\?\d*,\?\d*}\|\\@\%(>\|=\|!\|<=\|<!\)\)'
endfunction

function! ingo#regexp#parse#PositionAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any position atom.
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\\\%([\^<>]\|_\^\|_\$\|%[\^$V#]\|%[<>]\?''.\|%[<>]\?\d\+[lcv]\)\|[\^$]\)'
endfunction

function! ingo#regexp#parse#NumberEscapesExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any numbered escape; i.e. \%d; cp.
"   |E678|.
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%\%(d\%(\d\+\)\|o\%(\o\+\)\|x\%(\x\{1,2}\)\|u\%(\x\{1,4}\)\|U\%(\x\{1,8}\)\)'
endfunction

function! ingo#regexp#parse#CharacterClassesExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any character class; i.e. \w; cp.
"   |whitespace|.
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\_\?\([iIkKfFpPsSdDxXoOwWhHaAlLuU]\)'
endfunction

function! ingo#regexp#parse#OptionalSequenceExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches an optional sequence |/\%[|,
"   capturing the atoms inside [...].
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%\[\(\%(\[\[\]\|\[\]\]\|[^][]\|' . ingo#regexp#collection#Expr({'isBarePattern': 1}) . '\)\+\)\]'
endfunction

function! ingo#regexp#parse#GroupBranchExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any grouping or branching element:
"   \%(, \(, \|, \).
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(%\?(\|[|)]\)'
endfunction

function! ingo#regexp#parse#SingleCharacterExpr() abort
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\.\|\\_\.\)'
endfunction

function! ingo#regexp#parse#EscapedCharacterExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any escaped characters: \e, \n,
"   etc.
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\([etrbn]\)'
endfunction

function! ingo#regexp#parse#OtherAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any non-ordinary (i.e. not a
"   literal or escaped character) atom that isn't already matched by one of the
"   other atom expressions here.
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
    return '^\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%#=[012]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(zs\|ze\|[&123456789cCzmMvV]\)'
endfunction

function! ingo#regexp#parse#NonOrdinaryAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any non-ordinary (i.e. not a
"   literal character) atom, such as branches, multis, positions, collections,
"   escapes.
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
    return join([
    \   ingo#regexp#parse#GroupBranchExpr(),
    \   ingo#regexp#parse#MultiExpr(),
    \   ingo#regexp#parse#EscapedCharacterExpr(),
    \   ingo#regexp#parse#OtherAtomExpr(),
    \   ingo#regexp#parse#PositionAtomExpr(),
    \   ingo#regexp#parse#SingleCharacterExpr(),
    \   ingo#regexp#parse#OptionalSequenceExpr(),
    \   ingo#regexp#collection#Expr(),
    \   ingo#regexp#parse#CharacterClassesExpr(),
    \   ingo#regexp#parse#NumberEscapesExpr()
    \], '\|')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
