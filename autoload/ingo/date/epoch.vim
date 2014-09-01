" ingo/date/epoch.vim: Date conversion to the Unix epoch format (seconds since 1970).
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.001	27-Sep-2013	file creation

function! ingo#date#epoch#ConvertTo( date )
    " Unfortunately, Vim doesn't have a built-in function to convert an
    " arbitrary date to the Unix Epoch, and that is the only format which is
    " accepted by strftime(). Therefore, we need to rely on the Unix "date"
    " command (named "unixdate" on Windows; you need to have e.g. the GNU Win32
    " port installed).
    return str2nr(system(printf('%s -d %s +%%s', (ingo#os#IsWinOrDos() ? 'unixdate' : 'date'), ingo#compat#shellescape(a:date))))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
