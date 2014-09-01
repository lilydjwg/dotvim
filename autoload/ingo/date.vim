" ingo/date.vim: Functions for date and time.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.003	10-Nov-2013	Add month and year granularity to
"				ingo#date#HumanReltime().
"   1.010.002	08-Jul-2013	Move into ingo-library.
"	001	07-Oct-2011	file creation

function! s:Align( isShortFormat, isRightAligned, text )
    if a:isRightAligned
	return printf('%' . (a:isShortFormat ? 7 : 14) . 's', a:text)
    else
	return a:text
    endif
endfunction
function! s:Relative( isShortFormat, isRightAligned, isInFuture, time, timeunit )
    if a:isShortFormat
	let l:timestring = a:time . a:timeunit
    else
	let l:timestring = printf('%d %s%s', a:time, a:timeunit, (a:time == 1 ? '' : 's'))
    endif

    return s:Align(a:isShortFormat, a:isRightAligned, a:isInFuture ? 'in ' . l:timestring : l:timestring . ' ago')
endfunction
function! ingo#date#HumanReltime( timeElapsed, ... )
"******************************************************************************
"* PURPOSE:
"   Format a relative timespan in a format that is concise, not too precise, and
"   suitable for human understanding.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:timeElapsed   Time span in seconds; positive values mean time in the past.
"   a:options.shortformat   Flag whether a concise representation should be used
"			    (2 minutes -> 2m).
"   a:options.rightaligned  Flag whether the time text should be right-aligned,
"			    so that all results have the same width.
"* RETURN VALUES:
"   Text of the rendered time span, e.g. "just now", "2 minutes ago", "in 5
"   hours".
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isShortFormat = get(l:options, 'shortformat', 0)
    let l:isRightAligned = get(l:options, 'rightaligned', 0)
    let [l:now, l:seconds, l:minutes, l:hours, l:days, l:months, l:years] = (
    \   l:isShortFormat ?
    \       ['now', 's', 'm', 'h', 'd', 'mo.', 'y'] :
    \       ['just now', 'second', 'minute', 'hour', 'day', 'month', 'year']
    \)

    let l:isInFuture = 0
    let l:timeElapsed = a:timeElapsed
    if l:timeElapsed < 0
	let l:timeElapsed = -1 * l:timeElapsed
	let l:isInFuture = 1
    endif

    let l:secondsElapsed = l:timeElapsed % 60
    let l:minutesElapsed = (l:timeElapsed / 60) % 60
    let l:hoursElapsed = (l:timeElapsed / 3600) % 24
    let l:daysElapsed = (l:timeElapsed / (3600 * 24))
    let l:monthsElapsed = (l:timeElapsed / (3600 * 24 * 30))
    let l:yearsElapsed = (l:timeElapsed / (3600 * 24 * 365))

    if l:timeElapsed < 5
	return s:Align(l:isShortFormat, l:isRightAligned, l:now)
    elseif l:timeElapsed < 60
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, l:timeElapsed, l:seconds)
    elseif l:timeElapsed > 3540 && l:timeElapsed < 3660
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, 1, l:hours)
    elseif l:timeElapsed < 7200
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, (l:timeElapsed / 60), l:minutes)
    elseif l:timeElapsed < 86400
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, (l:timeElapsed / 3600), l:hours)
    elseif l:timeElapsed < 86400 * (30 + 31)
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, (l:timeElapsed / 86400), l:days)
    elseif l:timeElapsed < 86400 * (365 + 31)
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, (l:timeElapsed / 86400 / 30), l:months)
    else
	return s:Relative(l:isShortFormat, l:isRightAligned, l:isInFuture, (l:timeElapsed / 86400 / 365), l:years)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
