" ingo/selection/patternmatch.vim: Functions for matching inside the visual selection with \%V.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.001	23-May-2013	file creation

function! ingo#selection#patternmatch#AdaptEmptySelection()
"******************************************************************************
"* PURPOSE:
"   With :set selection=exclusive, one can create an empty selection with |v| or
"   |CTRL-V|. The |/\%V| atom does not match anywhere then. However, (built-in)
"   commands like gU do work on one selected character. For consistency, custom
"   mappings should, too. Invoke this function at the beginning of your mapping
"   to adapt the selection in this special case. You can then use a pattern with
"   |/\%V| without worrying.
"* ASSUMPTIONS / PRECONDITIONS:
"   A visual selection has previously been established.
"* EFFECTS / POSTCONDITIONS:
"   Changes the visual selection.
"   Clobbers v:count when active.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if &selection ==# 'exclusive' && virtcol("'<") == virtcol("'>")
	silent! execute "normal! gvl\<Esc>"
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
