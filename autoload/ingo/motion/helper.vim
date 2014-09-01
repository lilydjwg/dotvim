" ingo/motion/helper.vim: Functions for implementing custom motions.
"
" DEPENDENCIES:
"   - ingo/option.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.002	12-Jun-2014	Make test for 'virtualedit' option values also
"				account for multiple values.
"   1.016.001	11-Jan-2014	file creation

function! ingo#motion#helper#AdditionalMovement( ... )
"******************************************************************************
"* PURPOSE:
"   Make additional adaptive movement in a custom motion for certain modes.
"   The difference between normal mode, operator-pending and visual mode with
"   'selection' set to "exclusive" is that in the latter two, the motion must go
"   _past_ the final character, so that all characters of the text are selected.
"   This is done by appending a 'l' motion after the search for the text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSpecialLastLineTreatment    Optional flag that allows to turn off the
"				    special treatment at the end of the last
"				    line; by default enabled.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:isSpecialLastLineTreatment = (a:0 && a:1 || ! a:0)

    " The 'l' motion only works properly at the end of the line (i.e. when the
    " moved-over text is at the end of the line) when the 'l' motion is allowed
    " to move over to the next line. Thus, the 'l' motion is added temporarily
    " to the global 'whichwrap' setting. Without this, the motion would leave
    " out the last character in the line.
    let l:save_ww = &whichwrap
    set whichwrap+=l
    if l:isSpecialLastLineTreatment && line('.') == line('$') && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
	" For the last line in the buffer, that still doesn't work in
	" operator-pending mode, unless we can do virtual editing.
	let l:save_virtualedit = &virtualedit
	set virtualedit=onemore
	normal! l
	augroup IngoLibraryTempVirtualEdit
	    execute 'autocmd! CursorMoved * set virtualedit=' . l:save_virtualedit . ' | autocmd! IngoLibraryTempVirtualEdit'
	augroup END
    else
	normal! l
    endif
    let &whichwrap = l:save_ww
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
