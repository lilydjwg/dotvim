" ingo/syntaxitem.vim: Functions for retrieving information about syntax items.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.005.001	02-May-2013	file creation

if exists('*synstack')
function! ingo#syntaxitem#IsOnSyntax( pos, syntaxItemPattern )
    " Taking the example of comments:
    " Other syntax groups (e.g. Todo) may be embedded in comments. We must thus
    " check whole stack of syntax items at the cursor position for comments.
    " Comments are detected via the translated, effective syntax name. (E.g. in
    " Vimscript, "vimLineComment" is linked to "Comment".)
    for l:id in synstack(a:pos[1], a:pos[2])
	let l:actualSyntaxItemName = synIDattr(l:id, 'name')
	let l:effectiveSyntaxItemName = synIDattr(synIDtrans(l:id), 'name')
"****D echomsg '****' l:actualSyntaxItemName . '->' . l:effectiveSyntaxItemName
	if l:actualSyntaxItemName =~# a:syntaxItemPattern || l:effectiveSyntaxItemName =~# a:syntaxItemPattern
	    return 1
	endif
    endfor
    return 0
endfunction
else
function! ingo#syntaxitem#IsOnSyntax( pos, syntaxItemPattern )
    " Taking the example of comments:
    " Other syntax groups (e.g. Todo) may be embedded in comments. As the
    " synstack() function is not available, we can only try to get the actual
    " syntax ID and the one of the syntax item that determines the effective
    " color.
    " Comments are detected via the translated, effective syntax name. (E.g. in
    " Vimscript, "vimLineComment" is linked to "Comment".)
    for l:id in [synID(a:pos[1], a:pos[2], 0), synID(a:pos[1], a:pos[2], 1)]
	let l:actualSyntaxItemName = synIDattr(l:id, 'name')
	let l:effectiveSyntaxItemName = synIDattr(synIDtrans(l:id), 'name')
"****D echomsg '****' l:actualSyntaxItemName . '->' . l:effectiveSyntaxItemName
	if l:actualSyntaxItemName =~# a:syntaxItemPattern || l:effectiveSyntaxItemName =~# a:syntaxItemPattern
	    return 1
	endif
    endfor
    return 0
endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
