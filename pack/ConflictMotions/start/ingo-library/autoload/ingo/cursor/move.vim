" ingo/cursor/move.vim: Functions for moving the cursor.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.010.004	03-Jul-2013	Move into ingo-library.
"	003	08-Jan-2013	Reimplement wrapping by temporarily changing
"				'whichwrap' and 'virtualedit'; it's more robust
"				than the explicit checks and allows arbitrary
"				actions via new ingocursormove#Move().
"				Allow passing a count to ingocursormove#Left()
"				and ingocursormove#Right().
"	002	07-Jan-2013	I18N: FIX: Movement check in
"				ingocursormove#Right() doesn't properly consider
"				multi-byte character at the end of the line.
"	001	07-Jan-2013	file creation from autoload/surroundings.vim

function! ingo#cursor#move#Move( movement )
    let l:save_whichwrap = &whichwrap
    let l:save_virtualedit = &virtualedit
    set whichwrap=b,s,h,l,<,>,[,]
    set virtualedit=
	let l:originalPosition = getpos('.')    " Do this after 'virtualedit' has been reset; it may move the cursor back into the text.
	" Note: No try..catch here to abort a compound movement immediately.
	" Suppress beep with :silent!
	silent! execute 'normal!' a:movement
    let &virtualedit = l:save_virtualedit
    let &whichwrap = l:save_whichwrap

    return (getpos('.') != l:originalPosition)
endfunction

" Helper: move cursor one position left; with possible wrap to preceding line.
" Cursor does not move if at top of file.
function! ingo#cursor#move#Left( ... )
    return ingo#cursor#move#Move((a:0 ? a:1 : '') . 'h')
endfunction

" Helper: move cursor one position right; with possible wrap to following line.
" Cursor does not move if at end of file.
function! ingo#cursor#move#Right( ... )
    return ingo#cursor#move#Move((a:0 ? a:1 : '') . 'l')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
