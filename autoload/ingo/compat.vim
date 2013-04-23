" ingo/compat.vim: Functions for backwards compatibility with old Vim versions.
"
" DEPENDENCIES:
"   - EchoWithoutScrolling.vim autoload script (optional, for Vim 7.0 - 7.2)
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.004.001	04-Apr-2013	file creation

if exists('*strdisplaywidth')
    function! ingo#compat#strdisplaywidth( expr, ... )
	return call('strdisplaywidth', [a:expr] + a:000)
    endfunction
else
    if ! exists('*EchoWithoutScrolling#DetermineVirtColNum')
	runtime! autoload/EchoWithoutScrolling.vim
    endif
    if exists('*EchoWithoutScrolling#DetermineVirtColNum')
	function! ingo#compat#strdisplaywidth( expr, ... )
	    if a:0
		return EchoWithoutScrolling#DetermineVirtColNum(repeat(' ', a:1) . a:expr) - a:1
	    else
		return EchoWithoutScrolling#DetermineVirtColNum(a:expr)
	    endif
	endfunction
    else
	function! ingo#compat#strdisplaywidth( expr, ... )
	    return strlen(strtrans(substitute(a:expr, '\t', repeat(' ', &tabstop), 'g')))
	endfunction
    endif
endif

if exists('*strchars')
    function! ingo#compat#strchars( expr )
	return strchars(a:expr)
    endfunction
else
    function! ingo#compat#strchars( expr )
	return len(split(a:expr, '\zs'))
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
