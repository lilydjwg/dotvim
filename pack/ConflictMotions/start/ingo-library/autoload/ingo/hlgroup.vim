" ingo/hlgroup.vim: Functions around highlight groups.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.001	09-Feb-2017	file creation

function! ingo#hlgroup#LinksTo( name )
    redir => l:highlightOutput
	silent! execute 'highlight' a:name
    redir END
    redraw	" This is necessary because of the :redir done earlier.
    let l:linkedGroup = matchstr(l:highlightOutput, ' xxx links to \zs.*$')
    return l:linkedGroup
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
