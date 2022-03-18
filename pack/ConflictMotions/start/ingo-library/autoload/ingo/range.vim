" ingo/range.vim: Functions for dealing with ranges and their contents.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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
    let l:save_search = @/
    let l:keeppatterns = matchstr(ingo#compat#commands#keeppatterns(), '^keeppatterns$')
    try
	silent execute l:keeppatterns a:range . 'yank'
	let l:contents = @"
    finally
	if empty(l:keeppatterns) && @/ !=# l:save_search
	    call histdel('search', -1)
	endif
	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
    endtry

    return l:contents
endfunction

function! ingo#range#NetStart( ... )
"******************************************************************************
"* PURPOSE:
"   Vim accounts for closed folds and adapts <line1>,<line2> when passed a
"   :{from},{to} range, but not with a single :{lnum} range! As long as the
"   range is forwarded to Ex commands, that's fine. But if you do line
"   arithmethic or use low-level functions like |getline()|, you need to convert
"   via this function.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Optional line number; defaults to the current one.
"* RETURN VALUES:
"   Start line number of the fold covering the line, or the current / passed
"   line number itself.
"******************************************************************************
    let l:lnum = (a:0 ? a:1 : line('.'))
    return foldclosed(l:lnum) == -1 ? l:lnum : foldclosed(l:lnum)
endfunction
function! ingo#range#NetEnd( ... )
    let l:lnum = (a:0 ? a:1 : line('.'))
    return foldclosedend(l:lnum) == -1 ? l:lnum : foldclosedend(l:lnum)
endfunction

function! ingo#range#IsEntireBuffer( startLnum, endLnum )
    return (a:startLnum <= 1 && a:endLnum == line('$'))
endfunction

function! ingo#range#IsOutside( lnum, startLnum, endLnum )
    return (a:lnum < a:startLnum || a:lnum > a:endLnum)
endfunction
function! ingo#range#IsInside( lnum, startLnum, endLnum )
    return ! ingo#range#IsOutside(a:lnum, a:startLnum, a:endLnum)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
