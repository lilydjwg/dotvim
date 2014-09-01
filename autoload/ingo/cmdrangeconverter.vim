" ingo/cmdrangeconverter.vim: Functions to convert :command ranges.
"
" DEPENDENCIES:
"   - ingo/err.vim autoload script
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.002	17-Apr-2013	Add ingo#cmdrangeconverter#LineToBufferRange().
"   1.006.001	17-Apr-2013	file creation from ingointegration.vim

function! ingo#cmdrangeconverter#BufferToLineRange( cmd ) range
"******************************************************************************
"* MOTIVATION:
"   You want to invoke a command :Foo in a line-wise mapping <Leader>foo; the
"   command has a default range=%. The simplest solution is
"	nnoremap <Leader>foo :<C-u>.Foo<CR>
"   but that doesn't support a [count]. You cannot use
"	nnoremap <Leader>foo :Foo<CR>
"   neither, because then the mapping will work on the entire buffer if no
"   [count] is given. This utility function wraps the Foo command, passes the
"   given range, and falls back to the current line when no [count] is given:
"	:nnoremap <Leader>foo :call ingo#cmdrangeconverter#BufferToLineRange('Foo')<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"
"* PURPOSE:
"   Always pass the line-wise range to a:cmd.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:cmd   Ex command which has a default range=%.
"* RETURN VALUES:
"   True if successful; False when a Vim error or exception occurred.
"******************************************************************************
    call ingo#err#Clear()
    try
	execute a:firstline . ',' . a:lastline . a:cmd
	return 1
    catch
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction

function! ingo#cmdrangeconverter#LineToBufferRange( cmd )
"******************************************************************************
"* MOTIVATION:
"   You want to invoke a command that defaults to the current line (e.g. :s) in
"   a mapping <Leader>foo that defaults to the whole buffer, unless [count] is
"   given.
"   This utility function wraps the command, passes the given range, and falls
"   back to % when no [count] is given:
"	:nnoremap <Leader>foo :<C-u>if ! ingo#cmdrangeconverter#LineToBufferRange('s///g')<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"
"* PURPOSE:
"   Convert a line-range command to default to the entire buffer.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:cmd   Ex command which has a default range=.
"* RETURN VALUES:
"   True if successful; False when a Vim error or exception occurred.
"   Get the error message via ingo#err#Get().
"******************************************************************************
    call ingo#err#Clear()
    try
	if v:count
	    let l:range = (v:count == 1 ? '.' : '.,.+' . (v:count - 1))
	else
	    let l:range = '%'
	endif
	execute l:range . a:cmd
	return 1
    catch
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
