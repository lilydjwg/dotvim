" ingo/date/format.vim: Common date formats.
"
" DEPENDENCIES:
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2012-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if ! exists('g:IngoLibrary_PreferredDateFormat')
    let g:IngoLibrary_PreferredDateFormat = '%x'
endif

function! ingo#date#format#Epoch( ... )
    return call('strftime', ['%s'] + a:000)
endfunction
function! ingo#date#format#International( ... )
    return call('strftime', ['%d-%b-%Y'] + a:000)
endfunction
function! ingo#date#format#Preferred( ... )
    return call('strftime', [ingo#actions#ValueOrFunc(ingo#plugin#setting#GetBufferLocal('IngoLibrary_PreferredDateFormat'))] + a:000)
endfunction
function! ingo#date#format#Sortable( ... )
    return call('strftime', ['%Y-%m-%d'] + a:000)
endfunction
function! ingo#date#format#SortableNumeric( ... )
    return call('strftime', ['%Y%m%d'] + a:000)
endfunction
function! ingo#date#format#FilesystemCompatibleTimestamp( ... )
    return call('strftime', ['%Y%m%d-%H%M%S'] + a:000)
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
