" ingo/undo.vim: Functions for undo and dealing with changes.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#undo#GetChangeNumber()
"******************************************************************************
"* PURPOSE:
"   Get the current change number, for use e.g. with :undo {N}.
"   In contrast to changenr(), this number always represents the current state
"   of the buffer, also after undo. If necessary, the function creates a new
"   no-op change.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   May make an additional no-op change.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Change number, for use with :undo {N}. -1 if undo is not supported.
"******************************************************************************
    if ! ingo#undo#IsEnabled()
	return -1
    endif

    if exists('*undotree')
	let l:undotree = undotree()
	let l:isLastChange = (l:undotree.seq_cur == l:undotree.seq_last)
    else
	redir => l:undolistOutput
	    silent! undolist
	redir END
	let l:undoChangeNumber = str2nr(split(l:undolistOutput, "\n")[-1])
	let l:isLastChange = (l:undoChangeNumber == changenr())
    endif

    if ! l:isLastChange
	" Create a new undo point, to be sure to return to the current state,
	" and not some undone earlier state.
	silent! call setline('$', getline('$'))
"****D echomsg '**** no-op change'
    endif

    return changenr()
endfunction

function! ingo#undo#IsEnabled( ... )
"******************************************************************************
"* PURPOSE:
"   Check whether (at least N levels of) undo is enabled.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:N Number of undo levels that must be supported.
"* RETURN VALUES:
"   1 if (N / one) level of undo is supported, else 0.
"******************************************************************************
    if a:0
	let l:undolevels = (&undolevels == 0 ? 1 : &undolevels)
	return (l:undolevels >= a:1)
    else
	return (&undolevels >= 0)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
