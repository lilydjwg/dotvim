" ingo/str/fromrange.vim: Functions to create strings by transforming codepoint ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.002	28-Dec-2016	Split off
"				ingo#str#fromrange#GetTranslationStrings() from
"				ingo#str#fromrange#Tr().
"   1.029.001	14-Dec-2016	file creation from subs/Homoglyphs.vim

function! ingo#str#fromrange#GetAsList( ... )
"******************************************************************************
"* PURPOSE:
"   Get a List of characters with codepoints in the passed range.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr [, a:max [, a:stride]], as with |range()|.
"* RETURN VALUES:
"   List of characters.
"******************************************************************************
    return map(call('range', a:000), 'nr2char(v:val)')
endfunction
function! ingo#str#fromrange#Get( ... )
"******************************************************************************
"* PURPOSE:
"   Get a string of characters with codepoints in the passed range.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr [, a:max [, a:stride]], as with |range()|.
"* RETURN VALUES:
"   String of characters.
"******************************************************************************
    return join(map(call('range', a:000), 'nr2char(v:val)'), '')
endfunction


function! s:RangeToString( start, end )
    return join(
    \   map(
    \       range(a:start, a:end),
    \       'nr2char(v:val)'
    \   ),
    \   ''
    \)
endfunction
function! ingo#str#fromrange#GetTranslationStrings( mirrorMode, ranges )
"******************************************************************************
"* PURPOSE:
"   Generate source and destination character ranges from a:ranges.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:mirrorMode    0: Do not mirror
"		    1: Mirror a:range so that translation also works in the
"		       other direction.
"		    2: Only mirror, i.e. only translate back.
"   a:ranges        List of ranges; one of (also mixed) [source, destination] or
"		    [start, end, transformStart] codepoints.
"* RETURN VALUES:
"   [sourceRangeString, destinationRangeString]
"******************************************************************************
    let l:sources = ''
    let l:destinations = ''

    for l:range in a:ranges
	if len(l:range) == 3
	    let [l:start, l:end, l:transformStart] = l:range
	    let s = s:RangeToString(l:start, l:end)
	    let d = s:RangeToString(l:transformStart, l:transformStart + l:end - l:start)
	elseif len(l:range) == 2
	    let [s, d] = [nr2char(l:range[0]), nr2char(l:range[1])]
	else
	    throw 'ASSERT: Must pass either [start, end, transformStart] or [source, destination].'
	endif

	if a:mirrorMode != 2
	    let l:sources .= s
	    let l:destinations .= d
	endif
	if a:mirrorMode > 0
	    let l:sources .= d
	    let l:destinations .= s
	endif
    endfor

    return [l:sources, l:destinations]
endfunction
function! ingo#str#fromrange#Tr( text, mirrorMode, ranges )
"******************************************************************************
"* PURPOSE:
"   Translate the character ranges in a:ranges in a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be modified.
"   a:mirrorMode    0: Do not mirror
"		    1: Mirror a:range so that translation also works in the
"		       other direction.
"		    2: Only mirror, i.e. only translate back.
"   a:ranges        List of ranges; one of (also mixed) [source, destination] or
"		    [start, end, transformStart] codepoints.
"* RETURN VALUES:
"   Modified a:text.
"******************************************************************************
    return call('tr', [a:text] + ingo#str#fromrange#GetTranslationStrings(a:mirrorMode, a:ranges))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
