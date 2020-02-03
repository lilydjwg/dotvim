" ingo/compat/window.vim: Compatibility functions for windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	10-Oct-2016	file creation

if exists('*getcmdwintype')
function! ingo#compat#window#IsCmdlineWindow()
    return ! empty(getcmdwintype())
endfunction
elseif v:version >= 702
function! ingo#compat#window#IsCmdlineWindow()
    return bufname('') ==# '[Command Line]'
endfunction
else
function! ingo#compat#window#IsCmdlineWindow()
    return bufname('') ==# 'command-line'
endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
