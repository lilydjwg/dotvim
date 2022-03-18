" ingo/window/preview.vim: Functions for the preview window.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.005	13-Dec-2016	BUG: Optional a:position argument to
"				ingo#window#preview#SplitToPreview() is
"				mistakenly truncated to [1:2]. Inline the
"				l:cursor and l:bufnr variables; they are only
"				used in the function call, anyway.
"   1.021.004	06-Jul-2014	Support all imaginable argument variants of
"				ingo#window#preview#OpenFilespec(), so that it
"				can be used as a wrapper that encapsulates the
"				g:previewwindowsplitmode config and the
"				workaround for the absolute filespec due to the
"				CWD.
"   1.021.003	03-Jul-2014	Add ingo#window#preview#OpenFilespec(), a
"				wrapper around :pedit that performs the
"				fnameescape() and obeys the custom
"				g:previewwindowsplitmode.
"   1.020.002	02-Jun-2014	ENH: Allow passing optional a:tabnr to
"				ingo#window#preview#IsPreviewWindowVisible().
"				Factor out ingo#window#preview#OpenBuffer().
"				CHG: Change optional a:cursor argument of
"				ingo#window#preview#SplitToPreview() from
"				4-tuple getpos()-style to [lnum, col]-style.
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim
let s:save_cpo = &cpo
set cpo&vim

function! ingo#window#preview#OpenPreview( ... )
    " Note: We do not use :pedit to open the current file in the preview window,
    " because that command reloads the current buffer, which would fail (nobang)
    " / forcibly write (bang) it, and reset the current folds.
    "execute 'pedit! +' . escape( 'call setpos(".", ' . string(getpos('.')) . ')', ' ') . ' %'
    try
	" If the preview window is open, just go there.
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441:/
	" Else, temporarily open a dummy file. (There's no :popen command.)
	execute 'silent' (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '') (a:0 ? a:1 : '') 'pedit! +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile [No\ Name]'
	wincmd P
    endtry
endfunction
function! ingo#window#preview#OpenBuffer( bufnr, ... )
    if ! &l:previewwindow
	call ingo#window#preview#OpenPreview()
    endif

    " Load the passed buffer in the preview window, if it's not already there.
    if bufnr('') != a:bufnr
	silent execute a:bufnr . 'buffer'
    endif

    if a:0
	call cursor(a:1)
    endif
endfunction
function! ingo#window#preview#OpenFilespec( filespec, ... )
    " Load the passed filespec in the preview window.
    let l:options = (a:0 ? a:1 : {})
    let l:isSilent = get(l:options, 'isSilent', 1)
    let l:isBang = get(l:options, 'isBang', 1)
    let l:prefixCommand = get(l:options, 'prefixCommand', '')
    let l:exFileOptionsAndCommands = get(l:options, 'exFileOptionsAndCommands', '')
    let l:cursor = get(l:options, 'cursor', [])
    if ! empty(l:cursor)
	let l:exFileOptionsAndCommands = (empty(l:exFileOptionsAndCommands) ? '+' : l:exFileOptionsAndCommands . '|') .
	\   printf('call\ cursor(%d,%d)', l:cursor[0], l:cursor[1])
    endif

    execute (l:isSilent ? 'silent' : '')
    \   (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '')
    \   l:prefixCommand
    \   'pedit' . (l:isBang ? '!' : '')
    \   l:exFileOptionsAndCommands
    \   ingo#compat#fnameescape(a:filespec)

    " XXX: :pedit uses the CWD of the preview window. If that already contains a
    " file with another CWD, the shortened command is wrong. Always use the
    " absolute filespec instead of shortening it via
    " fnamemodify(a:filespec, " ':~:.')
endfunction
function! ingo#window#preview#SplitToPreview( ... )
    if &l:previewwindow
	wincmd p
	if &l:previewwindow | return 0 | endif
    endif

    " Clone current cursor position to preview window (which now shows the same
    " file) or passed position.
    call ingo#window#preview#OpenBuffer(bufnr(''), (a:0 ? a:1 : getpos('.')[1:2]))
    return 1
endfunction
function! ingo#window#preview#GotoPreview()
    if &l:previewwindow | return | endif
    try
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441:/
	call ingo#window#preview#SplitToPreview()
    endtry
endfunction


function! ingo#window#preview#IsPreviewWindowVisible( ... )
    for l:winnr in range(1, winnr('$'))
	if (a:0 ?
	\   gettabwinvar(a:1, l:winnr, '&previewwindow') :
	\   getwinvar(l:winnr, '&previewwindow')
	\)
	    " There's still a preview window.
	    return l:winnr
	endif
    endfor

    return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
