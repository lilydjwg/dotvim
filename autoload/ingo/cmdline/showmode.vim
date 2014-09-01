" ingo/cmdline/showmode.vim: Functions for the 'showmode' option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.002	20-Jun-2013	Indicate activation with return code.
"   1.009.001	18-Jun-2013	file creation from SnippetComplete.vim

function! ingo#cmdline#showmode#OneLineTemporaryNoShowMode()
    " An active 'showmode' setting may prevent the user from seeing the message
    " in a one-line command line. Thus, we temporarily disable the 'showmode'
    " setting.
    if ! &showmode || &cmdheight > 1
	return 0
    endif

    set noshowmode

    " Use a single-use autocmd to restore the 'showmode' setting when the cursor
    " is moved or insert mode is left.
    augroup IngoLibraryNoShowMode
	autocmd!
	autocmd CursorMovedI,InsertLeave * set showmode | autocmd! IngoLibraryNoShowMode
    augroup END
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
