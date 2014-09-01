" ingo/query/substitute.vim: Functions for confirming a command like :substitute//c.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.001	04-Mar-2014	file creation

function! s:Question( msg )
    echohl Question
    echo a:msg . ' (y/n/a/q/l/^E/^Y)?'
    echohl None
endfunction
function! ingo#query#substitute#Get( msg )
"******************************************************************************
"* PURPOSE:
"   Query a response like |:s_c|, with choices of yes, no, last, quit, Ctrl-E,
"   Ctrl-Y. The latter two are handled transparently by this function.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Moves the view on Ctrl-E / Ctrl-Y.
"* INPUTS:
"   a:msg   Message to be presented for acknowledging.
"* RETURN VALUES:
"   One of [ynlaq\e].
"******************************************************************************
    call s:Question(a:msg)

    while 1
	let l:choice = ingo#query#get#Char({'isBeepOnInvalid': 0, 'validExpr': "[ynl\<Esc>aq\<C-e>\<C-y>]"})
	if l:choice ==# "\<C-e>" || l:choice ==# "\<C-y>"
	    execute 'normal!' l:choice
	    redraw
	    call s:Question(a:msg)
	elseif l:choice ==# "\<Esc>"
	    return 'q'
	elseif ! empty(l:choice)
	    return l:choice
	endif
    endwhile
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
