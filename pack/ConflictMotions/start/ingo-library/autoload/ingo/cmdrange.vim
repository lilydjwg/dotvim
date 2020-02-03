" ingo/cmdrange.vim: Functions for working with command ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#cmdrange#FromCount( ... )
"******************************************************************************
"* PURPOSE:
"   Convert the passed a:count / v:count into a command-line range, defaulting
"   to the current line / a:defaultRange if count is 0.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:defaultRange  Optional default range when count is 0.
"   a:count         Optional given count.
"* RETURN VALUES:
"   Command-line range to be prepended to an Ex command.
"******************************************************************************
    let l:defaultRange = (a:0 && a:1 isnot# '' ? a:1 : '.')
    let l:count = (a:0 >= 2 ? a:2 : v:count)
    return (l:count ?
    \   (l:count == 1 ? '.' : '.,.+' . (l:count - 1)) :
    \   l:defaultRange
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
