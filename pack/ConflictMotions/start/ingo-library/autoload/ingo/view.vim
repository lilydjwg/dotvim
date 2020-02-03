" ingo/view.vim: Functions for saving and restoring the window's view.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:   Ingo Karkat <ingo@karkat.de>

" The functions here allow you to define internal mappings that, when they
" surround the right-hand side of your actual mapping, restore the current view
" in the current window. Define the right variant(s) based on the mapping
" mode(s), and whether a simple winsaveview() will do, or whether you need
" "extra strength" to relocate the current position via a temporary mark (when
" there are insertions / deletions above the current position, the recorded
" cursor position may be off).
"   noremap  <expr> <silent>  <SID>(WinSaveView)		ingo#view#Save(0)
"   inoremap <expr> <silent>  <SID>(WinSaveView)		ingo#view#Save(0)
"   noremap  <expr> <silent>  <SID>(WinSaveViewWithMark)	ingo#view#Save(1)
"   inoremap <expr> <silent>  <SID>(WinSaveViewWithMark)	ingo#view#Save(1)
" Use <Plug>(WinSaveView) from any mode at the beginning of a mapping to save
" the current window's view. This is a |:map-expr| which does not interfere with
" any pending <count> or mode.
"
" At the end of the mapping, use <Plug>(WinRestView) from normal mode to restore
" the view and cursor position.
"   nnoremap <expr> <silent>  <SID>(WinRestView) ingo#view#Restore()
" Example: >
"   nnoremap <script> <SID>(WinSaveView)<SID>MyMapping<SID>(WinRestView)
" or :execute the ingo#view#RestoreCommands() directly (e.g. if the mapping asks
" for input).

let s:save_count = 0
function! ingo#view#Save( isUseMark )
    let s:save_count = v:count
    let w:save_view = winsaveview()
    if a:isUseMark
	try
	    let w:save_mark = ingo#plugin#marks#FindUnused()
	    let l:markExpr = "'" . w:save_mark
	    call setpos(l:markExpr, getpos('.'))
	catch /^ReserveMarks:/
	    " If no marks are available, just use the saved view. Grabbing a
	    " used mark and clobber its position could be worse than just be off
	    " with the restored view.
	    unlet! w:save_mark
	endtry
    else
	unlet! w:save_mark
    endif
    return ''
endfunction
function! ingo#view#RestoreCommands()
    let l:commands = []
    if exists('w:save_view')
	call add(l:commands, 'call winrestview(w:save_view)|unlet w:save_view')
    endif
    if exists('w:save_mark')
	call add(l:commands, printf("execute 'silent! normal! g`%s'|call setpos(\"'%s\", [0, 0, 0, 0])|unlet! w:save_mark", w:save_mark, w:save_mark))
    endif
    return join(l:commands, '|')
endfunction
function! ingo#view#Restore()
    let l:commands = ingo#view#RestoreCommands()
    return (empty(l:commands) ? '' : "\<C-\>\<C-n>:" . ingo#view#RestoreCommands() . "\<CR>")
endfunction

" ingo#view#Restore[Commands]() clobber v:count, but you can for instance pass a
" Funcref to ingo#view#RestoredCount as the a:defaultCount optional argument to
" the repeatableMapping.vim functions to consider the saved value.
function! ingo#view#RestoredCount()
    return s:save_count
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
