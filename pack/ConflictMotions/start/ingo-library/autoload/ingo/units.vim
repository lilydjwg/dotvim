" ingo/units.vim: Functions for formatting number units.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#units#Format( number, ... )
"******************************************************************************
"* PURPOSE:
"   Format a:number in steps of a:base (e.g. 1000), appending the a:base (e.g.
"   ['', 'k', 'M'], and returning a number with a:precision digits after the
"   decimal point.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Original number to be formatted.
"   a:precision Number of digits returned after the decimal point. Default is 1.
"               Can also be a list; the element with the same index as a:units
"               is then used (using the last available for any additional
"               units).
"   a:units     List of unit strings, starting with factor 1, a:base, a:base *
"		a:base, ... Default is ['', 'k', 'M', 'G', ...]
"   a:base      Factor between the a:units; default 1000.
"* RETURN VALUES:
"   List of [formattedNumber, usedUnit].
"******************************************************************************
    let l:precisions = ingo#list#Make(a:0 > 0 ? a:1 : 1)
    let l:units = (a:0 > 1 ? a:2 : ['', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'])
    let l:base = (a:0 > 2 ? a:3 : 1000)

    for l:i in range(len(l:units))
	let l:baseNumber = pow(l:base, len(l:units) - l:i - 1)
	if a:number / float2nr(l:baseNumber) > 0
	    break
	endif
    endfor

    return [printf('%0.' . get(l:precisions, len(l:units) - l:i - 1, l:precisions[-1]) . 'f',
    \   a:number / l:baseNumber),
    \   get(l:units, len(l:units) - l:i - 1, '')
    \]
endfunction

function! ingo#units#FormatBytesDecimal( number, ... )
"******************************************************************************
"* PURPOSE:
"   Format a:number in decimal steps of 1000, using the metric units (KB, MB,
"   ...).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Original number to be formatted.
"   a:precision Number of digits returned after the decimal point.
"               Can also be a list; the element with the same index as a:units
"               is then used (using the last available for any additional
"               units). Default is [0, 1], so no fractions for bytes, and one
"               digit after the decimal point for everything else..
"* RETURN VALUES:
"   List of [formattedNumber, usedUnit].
"******************************************************************************
    return ingo#units#Format(a:number, (a:0 ? a:1 : [0, 1]), ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'], 1000)
endfunction
function! ingo#units#FormatBytesBinary( number, ... )
"******************************************************************************
"* PURPOSE:
"   Format a:number in binary steps of 1024, using the IEC units (KiB, MiB,
"   ...).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Original number to be formatted.
"   a:precision Number of digits returned after the decimal point.
"               Can also be a list; the element with the same index as a:units
"               is then used (using the last available for any additional
"               units). Default is [0, 1], so no fractions for bytes, and one
"               digit after the decimal point for everything else..
"* RETURN VALUES:
"   List of [formattedNumber, usedUnit].
"******************************************************************************
    return ingo#units#Format(a:number, (a:0 ? a:1 : [0, 1]), ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'], 1024)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
