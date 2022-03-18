" ingo/buffer/visible.vim: Functions to execute stuff in a visible buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.004	29-Jul-2016	FIX: Temporarily reset 'switchbuf' in
"				ingo#buffer#visible#Execute(), to avoid that
"				"usetab" switched to another tab page.
"   1.024.003	17-Mar-2015	ingo#buffer#visible#Execute(): Restore the
"				window layout when the buffer is visible but in
"				a window with 0 height / width. And restore the
"				previous window when the buffer isn't visible
"				yet. Add a check that the command hasn't
"				switched to another window (and go back if true)
"				before closing the split window.
"   1.023.002	07-Feb-2015	Use :close! in ingo#buffer#visible#Execute() to
"				handle modified buffers when :set nohidden, too.
"				ENH: Keep previous (last accessed) window on
"				ingo#buffer#visible#Execute().
"   1.008.001	11-Jun-2013	file creation from ingobuffer.vim

function! ingo#buffer#visible#Execute( bufnr, command )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command in a visible buffer.
"   Some commands (e.g. :update) operate in the context of the current buffer
"   and must therefore be visible in a window to be invoked. This function
"   ensures that the passed command is executed in the context of the passed
"   buffer number.
"* SEE ALSO:
"   To execute an Action in all buffers (temporarily made visible), use
"   ingo#actions#iterations#BufDo().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   The current window and buffer loaded into it remain the same.
"* INPUTS:
"   a:bufnr Buffer number of an existing buffer where the function should be
"   executed in.
"   a:command	Ex command to be invoked.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:winnr = bufwinnr(a:bufnr)
    let l:originalWindowLayout = winrestcmd()
    let l:currentWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    try
	if l:winnr == -1
	    " The buffer is hidden. Make it visible to execute the passed function.
	    " Use a temporary split window as ingo#buffer#temp#Execute() does, for
	    " all the reasons outlined there.
	    let l:save_switchbuf = &switchbuf | set switchbuf= | " :sbuffer should always open a new split / must not apply "usetab" (so we can :close it without checking).
		execute 'noautocmd silent keepalt leftabove sbuffer' a:bufnr
	    let &switchbuf = l:save_switchbuf | unlet l:save_switchbuf
	    let l:newWinNr = winnr()
	    try
		execute a:command
	    finally
		if winnr() != l:newWinNr
		    noautocmd silent execute l:newWinNr . 'wincmd w'
		endif
		noautocmd silent close!
	    endtry
	else
	    " The buffer is visible in at least one window on this tab page.
	    execute l:winnr . 'wincmd w'
	    execute a:command
	endif
    finally
	if exists('l:save_switchbuf') | let &switchbuf = l:save_switchbuf | endif
	silent execute l:previousWinNr . 'wincmd w'
	silent execute l:currentWinNr . 'wincmd w'
	silent! execute l:originalWindowLayout
    endtry
endfunction
function! ingo#buffer#visible#Call( bufnr, Funcref, arguments )
    return ingo#buffer#visible#Execute(a:bufnr, 'return call(' . string(a:Funcref) . ',' . string(a:arguments) . ')')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
