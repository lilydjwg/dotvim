" ingo/change/virtcols.vim: Functions for defining the change based on virtual columns.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#change#virtcols#Get( ... ) abort
"******************************************************************************
"* PURPOSE:
"   Get a selectionObject that contains information about the cell-based,
"   virtual screen columns that the last changed text occupies.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:type  Optional type (e.g. from g@); "char" is converted to a mode "v",
"           etc.
"* RETURN VALUES:
"   a:selection object
"******************************************************************************
    let l:selection =  {'startLnum': line("'["), 'startVirtCol': virtcol("'["), 'endLnum': line("']"), 'endVirtCol': virtcol("']"), 'effectiveEndVirtCol': virtcol("']")}
    if a:0
	let l:selection.mode = get({'char': 'v', 'line': 'V', 'block': "\<C-v>"}, a:1, a:1)
    endif
    return l:selection
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
