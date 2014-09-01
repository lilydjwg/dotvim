" ingo/fs/traversal.vim: Functions for traversal of the file system.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"   - ingo/fs/path.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.004	13-Sep-2013	Use operating system detection functions from
"				ingo/os.vim.
"   1.011.003	01-Aug-2013	Make a:path argument optional and default to the
"				current buffer's directory (as all existing
"				clients use that).
"				Add ingo#fs#traversal#FindDirUpwards().
"   1.003.002	26-Mar-2013	Rename to
"				ingo#fs#traversal#FindLastContainedInUpDir()
"	001	22-Mar-2013	file creation

function! ingo#fs#traversal#FindDirUpwards( Predicate, ... )
"******************************************************************************
"* PURPOSE:
"   Find directory where a:Predicate matches in a:path, searching upwards. Like
"   |finddir()|, but supports not just fixed directory names, but only upwards
"   search.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Predicate     Either a Funcref that gets invoked with a dirspec, or an
"		    expression where "v:val" is replaced with a dirspec.
"   a:dirspec   Optional starting directory. Should be absolute or at least in a
"		format that allows upward traversal via :h. If omitted, the
"		search starts from the current buffer's directory.
"* RETURN VALUES:
"   First dirspec where a:Predicate returns true.
"   Empty string when that never happens until the root directory is reached.
"******************************************************************************
    let l:dir = (a:0 ? a:1 : expand('%:p:h'))
    let l:prevDir = ''
    while l:dir !=# l:prevDir
	if ingo#actions#EvaluateWithValOrFunc(a:Predicate, l:dir)
	    return l:dir
	endif

	" Stop iterating after reaching the file system root.
	if ingo#os#IsWindows() && ingo#fs#path#IsUncPathRoot(l:dir)
	    break
	endif
	let l:prevDir = l:dir
	let l:dir = fnamemodify(l:dir, ':h')
    endwhile

    return ''
endfunction

function! ingo#fs#traversal#FindLastContainedInUpDir( expr, ... )
"******************************************************************************
"* PURPOSE:
"   Traversing upwards from the current buffer's directory, find the last
"   directory that yields a match for the a:expr glob.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  File glob that must match in each upwards directory.
"   a:dirspec   Optional starting directory. Should be absolute or at least in a
"		format that allows upward traversal via :h. If omitted, the
"		search starts from the current buffer's directory.
"* RETURN VALUES:
"   Dirspec of the highest directory that still matches a:expr.
"   Empty string if a:expr doesn't even match in the starting directory.
"******************************************************************************
    let l:dir = (a:0 ? a:1 : expand('%:p:h'))
    let l:prevDir = ''
    while l:dir !=# l:prevDir
	if empty(globpath(l:dir, a:expr, 1))
	    return l:prevDir
	endif
	let l:prevDir = l:dir
	let l:dir = fnamemodify(l:dir, ':h')
	if ingo#os#IsWindows() && ingo#fs#path#IsUncPathRoot(l:dir)
	    break
	endif
    endwhile

    return l:dir
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
