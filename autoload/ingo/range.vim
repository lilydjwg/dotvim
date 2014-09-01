" ingo/range.vim: Function for retrieving the contents of a range.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.001	23-Jul-2013	file creation from ingointegration.vim.

function! ingo#range#Get( range )
"******************************************************************************
"* PURPOSE:
"   Retrieve the contents of the passed range without clobbering any register.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:range A valid |:range|; when empty, the current line is used.
"* RETURN VALUES:
"   Text of the range on lines. Each line ends with a newline character.
"   Throws Vim error "E486: Pattern not found" when the range does not match.
"******************************************************************************
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    try
	silent execute a:range . 'yank'
	let l:contents = @"
    finally
	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
    endtry

    return l:contents
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
