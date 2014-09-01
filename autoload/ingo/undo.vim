" ingo/undo.vim: Functions for undo and dealing with changes.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.002	17-Jun-2014	Use built-in changenr() in
"				ingo#undo#GetChangeNumber(); actually, the
"				entire function could be replaced by the
"				built-in, if it would not just return one less
"				than the number of the undone change after undo.
"				We want the result to represent the current
"				change, regardless of what undo / redo was done
"				earlier. Change the implementation to test for
"				whether the current change is the last in the
"				buffer, and if not, make a no-op change to get
"				to an explicit change state.
"   1.019.001	25-Apr-2014	file creation

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
"   Change number, for use with :undo {N}.
"******************************************************************************
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
