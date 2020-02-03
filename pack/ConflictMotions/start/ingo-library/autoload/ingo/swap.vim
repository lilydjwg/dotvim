" ingo/swap.vim: Functions around the swap file.
"
" DEPENDENCIES:
"   - ingo/buffer/visible.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.001	29-Jan-2016	file creation

function! ingo#swap#GetNameImpl()
    " Use silent! so a failing redir (e.g. recursive redir call) won't hurt.
    silent! redir => o | silent swapname | redir END
    return (o[1:] ==# 'No swap file' ? '' : o[1:])
	return ''
    else
	return o[1:]
    endif
endfunction
function! ingo#swap#GetName( ... )
"******************************************************************************
"* PURPOSE:
"   Obtain the filespec of the swap file (like :swapname), for the current
"   buffer or the passed buffer number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:bufnr Optional buffer number of an existing buffer where the swap file
"	    should be obtained from.
"* RETURN VALUES:
"   filespec of current swapfile, or empty string.
"******************************************************************************
    if a:0
	silent! return ingo#buffer#visible#Call(a:1, 'ingo#swap#GetNameImpl', [])
    else
	return ingo#swap#GetNameImpl()
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
