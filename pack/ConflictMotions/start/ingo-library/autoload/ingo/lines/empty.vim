" ingo/lines/empty.vim: Functions to search for empty lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#lines#empty#IsEmptyLine( lnum )
    return empty(getline(a:lnum))
endfunction
function! ingo#lines#empty#IsEmptyLines( lnum1, lnum2 )
    return len(filter(getline(a:lnum1, a:lnum2), '! empty(v:val)')) == 0
endfunction

function! ingo#lines#empty#GetNextNonEmptyLnum( lnum )
    let l:lnum = (a:lnum < 0 ? line('$') + a:lnum + 2 : a:lnum) + 1
    while l:lnum <= line('$')
	if ingo#lines#empty#IsEmptyLine(l:lnum)
	    let l:lnum += 1
	else
	    return l:lnum
	endif
    endwhile
    return 0
endfunction
function! ingo#lines#empty#GetPreviousNonEmptyLnum( lnum )
    let l:lnum = (a:lnum < 0 ? line('$') + a:lnum + 2 : a:lnum) - 1
    while l:lnum >= 1
	if ingo#lines#empty#IsEmptyLine(l:lnum)
	    let l:lnum -= 1
	else
	    return l:lnum
	endif
    endwhile
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
