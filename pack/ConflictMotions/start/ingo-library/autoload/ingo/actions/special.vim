" ingo/actions/special.vim: Action execution within special environments.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/workingdir.vim autoload script
"
" Copyright: (C) 2016-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#actions#special#NoAutoChdir( ... )
"******************************************************************************
"* PURPOSE:
"   Execute a:Action with :set noautochdir.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or Ex commands to be executed.
"   ...         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   Result of Funcref, or empty string in case of Ex commands.
"******************************************************************************
    " Unfortunately, restoring the 'autochdir' option clobbers any temporary CWD
    " override. So we may have to restore the CWD, too.
    let l:save_cwd = getcwd()
    let l:chdirCommand = ingo#workingdir#ChdirCommand()

    " The 'autochdir' option adapts the CWD, so any (relative) filepath to the
    " filename in the other window would be omitted. Temporarily turn this off;
    " may be a little bit faster, too.
    if exists('+autochdir')
	let l:save_autochdir = &autochdir
	set noautochdir
    endif
    try
	return call(function('ingo#actions#ExecuteOrFunc'), a:000)
    finally
	if exists('l:save_autochdir')
	    let &autochdir = l:save_autochdir
	endif
	if getcwd() !=# l:save_cwd
	    execute l:chdirCommand ingo#compat#fnameescape(l:save_cwd)
	endif
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
