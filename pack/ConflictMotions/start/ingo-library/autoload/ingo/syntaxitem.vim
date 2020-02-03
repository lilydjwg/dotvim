" ingo/syntaxitem.vim: Functions for retrieving information about syntax items.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2011-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#syntaxitem#IsOnSyntax( pos, syntaxItemPattern, ... )
"******************************************************************************
"* PURPOSE:
"   Test whether on a:pos one of the syntax items in the stack matches
"   a:syntaxItemPattern.
"
"   Taking the example of comments:
"   Other syntax groups (e.g. Todo) may be embedded in comments. We must thus
"   check whole stack of syntax items at the cursor position for comments.
"   Comments are detected via the translated, effective syntax name. (E.g. in
"   Vimscript, "vimLineComment" is linked to "Comment".) A complication is with
"   fold markers. These are embedded in comments, so a stack for
"	" Public API for session persistence. {{{1
"	execute 'mksession' fnameescape(tempfile)
"   is this:
"	vimString -> vimExecute -> vimFoldTry -> vimFoldTryContainer ->
"	vimFuncBody -> vimFoldMarker -> vimLineComment
"   As we don't want to consider the fold marker comment, which is enclosing all
"   of the code, we add a stopItemPattern for 'FoldMarker$'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pos	        [bufnum, lnum, col, off] (as returned from |getpos()|)
"   a:syntaxItemPattern Regular expression for the syntax item name.
"   a:stopItemPattern	Regular expression for a syntax item name that stops
"			looking further down the syntax stack.
"* RETURN VALUES:
"   0 if no syntax name on the stack matches a:syntaxItemPattern, or a syntax
"   name higher on the stack already matches a:stopItemPattern. Else 1.
"******************************************************************************
    for l:id in reverse(ingo#compat#synstack(a:pos[1], a:pos[2]))
	let l:actualSyntaxItemName = synIDattr(l:id, 'name')
	let l:effectiveSyntaxItemName = synIDattr(synIDtrans(l:id), 'name')
"****D echomsg '****' l:actualSyntaxItemName . '->' . l:effectiveSyntaxItemName
	if a:0 && ! empty(a:1) && (l:actualSyntaxItemName =~# a:1 || l:effectiveSyntaxItemName =~# a:1)
	    return 0
	endif
	if l:actualSyntaxItemName =~# a:syntaxItemPattern || l:effectiveSyntaxItemName =~# a:syntaxItemPattern
	    return 1
	endif
    endfor
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
