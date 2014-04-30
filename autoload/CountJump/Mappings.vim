" CountJump/Mappings.vim: Utility functions to create the mappings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.83.002	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.60.001	27-Mar-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! CountJump#Mappings#MakeMotionKey( isForward, keys )
    return (a:keys =~# '^<Plug>' ?
    \   printf(a:keys, (a:isForward ? 'Forward' : 'Backward')) :
    \   (a:isForward ? ']' : '[') . a:keys
    \)
endfunction
function! CountJump#Mappings#MakeTextObjectKey( type, keys )
    return (a:keys =~# '^<Plug>' ?
    \   printf(a:keys, (a:type ==# 'i' ? 'Inner' : 'Outer')) :
    \   a:type . a:keys
    \)
endfunction
function! CountJump#Mappings#EscapeForFunctionName( text )
    let l:text = a:text

    " Strip off a <Plug> prefix.
    let l:text = substitute(l:text, '^\C<Plug>', '', '')

    " Convert all non-alphabetical characters to their hex value to create a
    " valid function name.
    let l:text = substitute(l:text, '\A', '\=char2nr(submatch(0))', 'g')

    return l:text
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
