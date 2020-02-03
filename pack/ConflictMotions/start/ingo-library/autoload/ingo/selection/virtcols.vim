" ingo/selection/virtcols.vim: Functions for defining a visual selection based on virtual columns.
"
" DEPENDENCIES:
"   - ingo/cursor.vim autoload script
"
" Copyright: (C) 2018-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#selection#virtcols#Get()
"******************************************************************************
"* PURPOSE:
"   Get a selectionObject that contains information about the cell-based,
"   virtual screen columns that the current visual selection occupies.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   a:selection object
"******************************************************************************
    let l:endVirtCol = virtcol("'>")
    let l:effectiveEndVirtCol = l:endVirtCol - (&selection ==# 'exclusive' ? 1 : 0)
    return {'mode': visualmode(), 'startLnum': line("'<"), 'startVirtCol': virtcol("'<"), 'endLnum': line("'>"), 'endVirtCol': l:endVirtCol, 'effectiveEndVirtCol': l:effectiveEndVirtCol }
endfunction

function! ingo#selection#virtcols#DefineAndExecute( selectionObject, command )
"******************************************************************************
"* PURPOSE:
"   Set / restore the visual selection based on the passed a:selectionObject and
"   execute a:command on it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the visual selection.
"   Executes a:command.
"* INPUTS:
"   a:selectionObject   Obtained from ingo#selection#virtcols#Get().
"   a:command           Ex command to work on the visual selection, e.g.
"			'normal! y' to yank the contents.
"* RETURN VALUES:
"   None.
"******************************************************************************
    call ingo#cursor#Set(a:selectionObject.startLnum, a:selectionObject.startVirtCol)
    execute 'normal!' a:selectionObject.mode
    call ingo#cursor#Set(a:selectionObject.endLnum, a:selectionObject.endVirtCol)
    execute a:command
endfunction
function! ingo#selection#virtcols#Set( selectionObject )
"******************************************************************************
"* PURPOSE:
"   Set / restore the visual selection based on the passed a:selectionObject.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the visual selection.
"* INPUTS:
"   a:selectionObject   Obtained from ingo#selection#virtcols#Get().
"* RETURN VALUES:
"   None.
"******************************************************************************
    call ingo#selection#virtcols#DefineAndExecute(a:selectionObject, "normal! \<Esc>")
endfunction

function! ingo#selection#virtcols#GetLimitingPatterns() abort
"******************************************************************************
"* PURPOSE:
"   Get regexp atoms that limit buffer searches to within the current selection
"   (on a best-effort basis for blockwise selections).
"* ASSUMPTIONS / PRECONDITIONS:
"   A previous selection exists.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   [startPattern, endPattern]; these can be further combined with /\%V atoms to
"   limit their applicability to the current selection.
"******************************************************************************
    let l:sel= ingo#selection#virtcols#Get()

    if l:sel.mode ==# 'v'
	return [
	\   ingo#regexp#virtcols#StartAnchorPattern(l:sel.startLnum, l:sel.startVirtCol),
	\   ingo#regexp#virtcols#EndAnchorPattern(l:sel.endLnum, l:sel.effectiveEndVirtCol)
	\]
    elseif l:sel.mode ==# 'V'
	return [
	\   ingo#regexp#virtcols#StartAnchorPattern(l:sel.startLnum),
	\   ingo#regexp#virtcols#EndAnchorPattern(l:sel.endLnum)
	\]
    else
	" Because of the possibility of a jagged blockwise-to-end selection
	" (which we could only detect by grabbing the current selected text),
	" the end assertion can only limit to the last line, not more.
	return [
	\   ingo#regexp#virtcols#StartAnchorPattern(l:sel.startLnum, l:sel.startVirtCol),
	\   ingo#regexp#virtcols#EndAnchorPattern(l:sel.endLnum)
	\]
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
