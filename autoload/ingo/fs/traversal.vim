" ingo/fs/traversal.vim: Functions for travelsal of the file system.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.003.002	26-Mar-2013	Rename to
"				ingo#fs#traversal#FindLastContainedInUpDir()
"	001	22-Mar-2013	file creation

function! ingo#fs#traversal#FindLastContainedInUpDir( name, path )
    let l:dir = a:path
    let l:prevDir = ''
    while l:dir !=# l:prevDir
	if empty(globpath(l:dir, a:name, 1))
	    return l:prevDir
	endif
	let l:prevDir = l:dir
	let l:dir = fnamemodify(l:dir, ':h')
	if (has('win32') || has('win64')) && l:dir =~ '^\\\\[^\\]\+$'
	    break
	endif
    endwhile

    return l:dir
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
