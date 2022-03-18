" ingo/folds/persistence.vim: Functions to persist and restore manual folds.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.001	01-Jan-2015	file creation

function! ingo#folds#persistence#SaveManualFolds()
    if &foldmethod !=# 'manual'
	return ''
    endif

    let l:filespec = tempname()
    let l:save_viewoptions = &viewoptions
    set viewoptions=folds
    try
	execute 'mkview' ingo#compat#fnameescape(l:filespec)
	return l:filespec
    finally
	let &viewoptions = l:save_viewoptions
    endtry

    return ''
endfunction
function! ingo#folds#persistence#RestoreManualFolds( handle )
    if empty(a:handle)
	return
    endif

    silent! execute 'source' ingo#compat#fnameescape(a:handle)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
