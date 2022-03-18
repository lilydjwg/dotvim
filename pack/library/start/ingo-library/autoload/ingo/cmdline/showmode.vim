" ingo/cmdline/showmode.vim: Functions for the 'showmode' option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.003	26-Jan-2016	Add ingo#cmdline#showmode#TemporaryNoShowMode()
"				variant of
"				ingo#cmdline#showmode#OneLineTemporaryNoShowMode().
"   1.009.002	20-Jun-2013	Indicate activation with return code.
"   1.009.001	18-Jun-2013	file creation from SnippetComplete.vim

let s:record = []
function! ingo#cmdline#showmode#TemporaryNoShowMode()
"******************************************************************************
"* PURPOSE:
"   An active 'showmode' setting may prevent the user from seeing the message in
"   a command line. Thus, we temporarily disable the 'showmode' setting.
"   Sometimes, this only happens in a single-line command line, but :echo'd text
"   is visible when 'cmdline' is larger than 1. For that, use
"   ingo#cmdline#showmode#OneLineTemporaryNoShowMode().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Boolean flag whether the temporary mode has been activated.
"******************************************************************************
    if ! &showmode || &cmdheight > 1
	return 0
    endif

    set noshowmode
    let s:record = ingo#record#Position(0)
    let s:record[2] += 1

    " Use a single-use autocmd to restore the 'showmode' setting when the cursor
    " is moved or insert mode is left.
    augroup IngoLibraryNoShowMode
	autocmd!

	" XXX: After a cursor move, the mode message doesn't instantly appear
	" again. A jump with scrolling or another mode change has to happen.
	" Neither :redraw nor :redrawstatus will do, but apparently :echo
	" triggers an update.
	autocmd CursorMovedI * if s:record != ingo#record#Position(0) | set showmode | echo '' | execute 'autocmd! IngoLibraryNoShowMode' | endif

	autocmd InsertLeave  * if s:record != ingo#record#Position(0) | set showmode |           execute 'autocmd! IngoLibraryNoShowMode' | endif
    augroup END
    return 1
endfunction
function! ingo#cmdline#showmode#OneLineTemporaryNoShowMode()
    if &cmdheight > 1
	return 0
    endif
    return ingo#cmdline#showmode#TemporaryNoShowMode()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
