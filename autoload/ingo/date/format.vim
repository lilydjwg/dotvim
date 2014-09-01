" ingo/date/format.vim: Common date formats.
"
" DEPENDENCIES:
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.003	16-Sep-2013	Allow to pass optional date to all functions.
"   1.014.002	13-Sep-2013	Move into ingo-library.
"				Use operating system detection functions from
"				ingo/os.vim.
"	001	14-Apr-2012	file creation from InsertDate.vim

function! ingo#date#format#International( ... )
    return call('strftime', ['%d-%b-%Y'] + a:000)
endfunction
function! ingo#date#format#Human( ... )
    return call('strftime', ['%d. %b %Y'] + a:000)
endfunction
function! ingo#date#format#Sortable( ... )
    return call('strftime', ['%Y-%m-%d'] + a:000)
endfunction
function! ingo#date#format#SortableNumeric( ... )
    return call('strftime', ['%Y%m%d'] + a:000)
endfunction
function! ingo#date#format#InternetTimestamp( ... )
    " RFC 3339 Internet Date / Time "1996-12-19T16:39:57-08:00"
    if ingo#os#IsWindows()
	" Windows doesn't support %:z, and even returns "either the time-zone
	" name or time zone abbreviation, depending on registry settings" (e.g.
	" "Romance Daylight Time", so we hard-code our CET / CEST offset
	" depending on the outcome.
	return call('strftime', ['%Y-%m-%dT%H:%M:%S'] + a:000) . (call('strftime', ['%z'] + a:000) =~? '\<daylight\>\|\<CEST\>' ? '+02:00' : '+01:00')
    else
	" Ubuntu 10.04 doesn't support %:z yet, but %z works, so insert the
	" required colon afterwards.
	let l:colonZItem = call('strftime', ['%:z'] + a:000)
	return call('strftime', ['%Y-%m-%dT%H:%M:%S'] + a:000) . (l:colonZItem ==# '%:z' ? substitute(call('strftime', ['%z'] + a:000), '\(\d\d\)\(\d\d\)', '\1:\2', '') : l:colonZItem)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
