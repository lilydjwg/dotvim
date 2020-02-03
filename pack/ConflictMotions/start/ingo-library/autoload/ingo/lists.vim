" ingo/lists.vim: Functions to compare Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#lists#StartsWith( list, sublist, ... )
    if len(a:list) < len(a:sublist)
	return 0
    elseif len(a:sublist) == 0
	return 1
    endif

    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (a:list[0 : len(a:sublist) - 1] ==? a:sublist)
    else
	return (a:list[0 : len(a:sublist) - 1] ==# a:sublist)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
