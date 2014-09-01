" ingo/smartcase.vim: Functions for SmartCase searches.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.003	24-Jun-2014	ENH: For a single word that so far didn't change
"				the SmartCase pattern, allow for an optional
"				preceding or trailing non-alphabetic keyword
"				separator. This makes the
"				ChangeGloballySmartCase replacement of "foo"
"				also work correctly on FOO_BAR.
"   1.021.002	20-Jun-2014	Also handle regexp atoms in
"				ingo#smartcase#FromPattern(). This isn't
"				required by the (literal text, very nomagic)
"				original use case, but for the arbitrary
"				patterns in CmdlineSpecialEdits.vim.
"   1.021.001	20-Jun-2014	file creation from plugin/ChangeGloballySmartCase.vim
let s:save_cpo = &cpo
set cpo&vim

function! ingo#smartcase#IsSmartCasePattern( pattern )
    return (a:pattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\c' && a:pattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\A\\[?=]')
endfunction
function! s:Escape( atom )
    " Anything larger than two characters is a special regexp atom that must be
    " kept as-is.
    return (len(a:atom) > 2 ? a:atom : '\A\=')
endfunction
function! ingo#smartcase#FromPattern( pattern, ... )
    let l:pattern = a:pattern
    let l:additionalEscapeCharacters = (a:0 ? a:1 : '')

    " Make all non-alphabetic delimiter characters and whitespace optional.
    " Keep any regexp atoms, like \<, \%# (the 3+ character ones must be
    " explicitly matched).
    " As backslashes are escaped, they must be handled separately. Same for any
    " escaped substitution separator.
    let l:pattern = substitute(l:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\\\@!\A\)\|' .
    \   '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%([' . l:additionalEscapeCharacters . '\\]\|' .
    \       '%[$^#<>(]\|%[<>]\?''\|@\%(=\|!\|<=\|<!\|>\)\|_[\[$^.]\|{[-[:digit:],]*}' .
    \   '\)',
    \   '\=s:Escape(submatch(0))', 'g'
    \)
    " Allow delimiters between CamelCase fragments to catch all variants.
    let l:pattern = substitute(l:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\(\l\)\(\u\)', '\1\\A\\=\2', 'g')

    if l:pattern ==# a:pattern
	" The smartcase'ing failed to extend the pattern. This is a single
	" all-lower or -uppercase alphabetic word. Allow for an optional
	" preceding or trailing non-alphabetic keyword separator.
	" Limit to keywords here to only match stuff like "_", but not arbitrary
	" stuff around (e.g. "'foo" in "'foo bar'", which would result in
	" "'foo'quux bar" instead of the desired "'fooQuux bar").
	let l:pattern = printf('\%%(\%%(\A\&\k\)\=%s\|%s\%%(\A\&\k\)\=\)', l:pattern, l:pattern)
    endif

    return '\c' . l:pattern
endfunction
function! ingo#smartcase#Undo( smartCasePattern )
    return substitute(a:smartCasePattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\(c\|A\\[?=]\)', '', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
