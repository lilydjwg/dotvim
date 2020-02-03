" ingo/motion/omap.vim: Helper function to repeat special operator-pending mappings.
"
" DEPENDENCIES:
"   - repeat.vim (vimscript #2136) autoload script (optional)
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.001	15-Jan-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#motion#omap#repeat( repeatMapping, operator, count )
    if a:operator ==# 'y' && &cpoptions !~# 'y'
	" A yank usually doesn't repeat.
	return
    endif

    silent! call repeat#set(a:operator . a:repeatMapping .
    \   (a:operator ==# 'c' ? "\<Plug>(IngoLibraryOmapRepeatReinsert)" : ''),
    \   a:count
    \)
endfunction

" This is for the special repeat of a "c" command, to insert the last entered
" text and leave insert mode. We define a :noremap so that any user mappings do
" not affect this.
inoremap <Plug>(IngoLibraryOmapRepeatReinsert) <C-r>.<Esc>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
