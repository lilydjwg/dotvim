" ingo/print.vim: Functions for printling lines.
"
" DEPENDENCIES:
"   - ingo/window/dimensions.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.015.001	22-Nov-2013	file creation

function! ingo#print#Number( lnum, ... )
"******************************************************************************
"* PURPOSE:
"   Like :number, but does not move the cursor to the line, and only prints the
"   passed a:lnum, not all lines in a (potential) closed fold.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   :echos output.
"* INPUTS:
"   a:lnum      Line number; when the line does not exist, nothing is printed.
"   a:hlgroup   Optional highlight group for the number, default is "LineNr".
"* RETURN VALUES:
"   1 is line exists and was printed; 0 otherwise.
"******************************************************************************
    if a:lnum < 1 || a:lnum > line('$')
	return 0
    endif

    execute 'echohl' (a:0 ? a:1 : 'LineNr')
    echo printf('%' . (ingo#window#dimensions#GetNumberWidth(1) - 1) . 'd ', a:lnum)
    echohl None
    echon getline(a:lnum)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
