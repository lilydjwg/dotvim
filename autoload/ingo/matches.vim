" ingo/matches.vim: Functions for pattern matching.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.002	15-Oct-2013	Replace conditional with ingo#list#Make().
"   1.004.001	07-Apr-2013	file creation

function! s:Count()
    let s:matchCnt += 1
    return submatch(0)
endfunction
function! ingo#matches#CountMatches( text, pattern )
    let s:matchCnt = 0
    for l:line in ingo#list#Make(a:text)
	call substitute(l:line, a:pattern, '\=s:Count()', 'g')
    endfor
    return s:matchCnt
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
