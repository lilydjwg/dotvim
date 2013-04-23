" ingo/window/preview.vim: Functions for the preview window.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	08-Apr-2013	file creation from autoload/ingowindow.vim

function! ingo#window#preview#OpenPreview( ... )
    " Note: We do not use :pedit to open the current file in the preview window,
    " because that command reloads the current buffer, which would fail (nobang)
    " / forcibly write (bang) it, and reset the current folds.
    "execute 'pedit! +' . escape( 'call setpos(".", ' . string(getpos('.')) . ')', ' ') . ' %'
    try
	" If the preview window is open, just go there.
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
	" Else, temporarily open a dummy file. (There's no :popen command.)
	execute 'silent' (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '') (a:0 ? a:1 : '') 'pedit +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile [No\ Name]'
	wincmd P
    endtry
endfunction
function! ingo#window#preview#SplitToPreview( ... )
    if &l:previewwindow
	wincmd p
	if &l:previewwindow | return 0 | endif
    endif

    let l:cursor = getpos('.')
    let l:bufnum = bufnr('')

    call ingo#window#preview#OpenPreview()

    " Load the current buffer in the preview window, if it's not already there.
    if bufnr('') != l:bufnum
	silent execute l:bufnum . 'buffer'
    endif

    " Clone current cursor position to preview window (which now shows the same
    " file) or passed position.
    call setpos('.', (a:0 ? a:1 : l:cursor))
    return 1
endfunction
function! ingo#window#preview#GotoPreview()
    if &l:previewwindow | return | endif
    try
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
	call ingo#window#preview#SplitToPreview()
    endtry
endfunction


function! ingo#window#preview#IsPreviewWindowVisible()
    for l:winnr in range(1, winnr('$'))
	if getwinvar(l:winnr, '&previewwindow')
	    " There's still a preview window.
	    return l:winnr
	endif
    endfor

    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
