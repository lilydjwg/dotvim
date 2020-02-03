" ingo/date/epoch.vim: Date conversion to the Unix epoch format (seconds since 1970).
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if ! exists('g:IngoLibrary_DateCommand')
    let g:IngoLibrary_DateCommand = (ingo#os#IsWinOrDos() ? 'unixdate' : 'date')
endif

function! ingo#date#epoch#ConvertTo( date )
    " Unfortunately, Vim doesn't have a built-in function to convert an
    " arbitrary date to the Unix Epoch, and that is the only format which is
    " accepted by strftime(). Therefore, we need to rely on the Unix "date"
    " command (named "unixdate" on Windows; you need to have e.g. the GNU Win32
    " port installed).
    return str2nr(system(printf('%s -d %s +%%s', ingo#compat#shellescape(g:IngoLibrary_DateCommand), ingo#compat#shellescape(a:date))))
endfunction

if exists('g:IngoLibrary_NowEpoch')
    function! ingo#date#epoch#Now()
	return g:IngoLibrary_NowEpoch
    endfunction
else
    function! ingo#date#epoch#Now()
"******************************************************************************
"* PURPOSE:
"   Get the Unix Epoch for the current date and time.
"   Supports a "testing mode" by defining g:IngoLibrary_NowEpoch (before first
"   use of this module) with the constant value to be returned instead.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Integer representing the seconds since 1970 as of now.
"******************************************************************************
	return localtime()
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
