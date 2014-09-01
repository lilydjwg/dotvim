" ingo/ftplugin/windowsettings.vim: Function to undo window settings for a buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.005	09-Jan-2014	BUG: Wrap :autocmd! undo_ftplugin_N in :execute
"				to that superordinated ftplugins can append
"				additional undo commands without causing "E216:
"				No such group or event:
"				undo_ftplugin_N|setlocal".
"   1.011.004	23-Jul-2013	Move into ingo-library.
"	003	23-Nov-2012	ENH: Correctly unset the window-local settings
"				when doing a :split otherfile, and when the
"				buffer is still visible in another window, so
"				the BufWinLeave event isn't triggered.
"	002	14-Feb-2011	BUG: Mismatch in augroup names resulted in E216.
"	001	27-Jan-2011	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#ftplugin#windowsettings#Undo( windowSettings )
"******************************************************************************
"* PURPOSE:
"   Filetype settings that have buffer-scope are undone via the b:undo_ftplugin
"   variable; some ftplugins may also want to set window-scoped settings like
"   'colorcolumn'. These must be undone when the buffer is removed from a window
"   and restored when the buffer displayed again; otherwise, these settings will
"   pollute other buffers when they are displayed in the same window. This
"   function sets up the correct autocmds and undo actions for such window-local
"   settings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets up buffer-local autocmds in augroup "undo_ftplugin_N", where N is the
"   buffer number.
"   Sets up window-local variables to detect and handle all possible situations.
"   Appends undo actions to b:undo_ftplugin.
"* INPUTS:
"   a:windowSettings	Space-separated list of window-local settings to be set
"			for this filetype, e.g. "colorcolumn=+1 stl=%s\ %P"
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:windowSettingNames = map(split(a:windowSettings, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<! '), 'substitute(v:val, "=.*$", "", "")')
    let l:windowUndoSettings = join(map(l:windowSettingNames, 'v:val . "<"'), ' ')

    " Set the window-local settings for now.
    execute 'setlocal' a:windowSettings

    let l:augroupName = 'undo_ftplugin_' . bufnr('')
    let l:bufWinSettings = string([bufnr(''), l:windowUndoSettings])
    execute 'augroup' l:augroupName
	autocmd!
	" These are the basic handlers that set and unset the window-local
	" settings when the buffer is displayed and removed from its window.
	execute 'autocmd BufWinEnter <buffer>   let  w:hasBufWinSettings = '.l:bufWinSettings.' | setlocal' a:windowSettings
	execute 'autocmd BufWinLeave <buffer> unlet! w:hasBufWinSettings                        | setlocal' l:windowUndoSettings

	" When splitting the window, that may mean that another buffer is about
	" to be loaded into it (:split otherfile). We detect the split on the
	" immediate WinEnter event because the w:hasBufWinSettings variable does
	" not inherit to the split window.
	" To have the window-local settings unset by the undo_ftplugin_other
	" group's autocmds, we set another w:windowUndoSettings variable for it
	" that contains the necessary commands.
	execute 'autocmd WinEnter    <buffer> ' .
	\   'if ! exists("w:hasBufWinSettings") | let w:windowUndoSettings = ' . string(l:windowUndoSettings) . ' | endif'
	" Should this :split have been intended as a cloning of the current
	" buffer, we detect this when the window is left with the same buffer
	" intact, and then also define w:hasBufWinSettings, so that it is
	" identical to the original.
	execute 'autocmd WinLeave    <buffer>   let  w:hasBufWinSettings = '.l:bufWinSettings.' | unlet! w:windowUndoSettings'
    augroup END
    augroup undo_ftplugin_other
	" When a buffer is loaded into a window that resulted from a split of a
	" buffer with window-local settings, undo them.
	" When a buffer is loaded into a window that contained a buffer with
	" window-local settings, and that buffer is still visible in another
	" window, the BufWinLeave event didn't fire, and therefore the
	" window-local settings weren't unset yet. Unset it now. (Unless this is
	" the buffer with the window-local settings itself.)
	autocmd! BufWinEnter *
	\   if exists('w:windowUndoSettings') |
	\       execute 'setlocal' w:windowUndoSettings |
	\       unlet w:windowUndoSettings |
	\   elseif exists('w:hasBufWinSettings') && w:hasBufWinSettings[0] != expand('<abuf>') |
	\       execute 'setlocal' w:hasBufWinSettings[1] |
	\       unlet w:hasBufWinSettings |
	\   endif
    augroup END

    let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . '|' : '') . 'setlocal ' . l:windowUndoSettings . ' | execute "autocmd! ' . l:augroupName . '"'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
