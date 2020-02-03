" ingo/filetype.vim: Functions for the buffer's filetype(s).
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script

" Copyright: (C) 2012-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#filetype#Is( filetypes )
    for l:ft in split(&filetype, '\.')
	if (index(ingo#list#Make(a:filetypes), l:ft) != -1)
	    return 1
	endif
    endfor

    return 0
endfunction

function! ingo#filetype#GetPrimary( ... )
    return get(split((a:0 ? a:1 : &filetype), '\.'), 0, '')
endfunction
function! ingo#filetype#IsPrimary( filetypes )
    return (index(ingo#list#Make(a:filetypes), ingo#filetype#GetPrimary()) != -1)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
