" TextObject.vim: Create custom text objects via jumps over matching lines. 
"
" DEPENDENCIES:
"   - CountJump/Region.vim, CountJump/TextObjects.vim autoload scripts. 
"
" Copyright: (C) 2010 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.40.001	20-Dec-2010	file creation

function! s:EscapeForFunctionName( text )
    " Convert all non-alphabetical characters to their hex value to create a
    " valid function name. 
    return substitute(a:text, '\A', '\=char2nr(submatch(0))', 'g')
endfunction
function! s:function(name)
    return function(substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'),''))
endfunction 
function! CountJump#Region#TextObject#Make( mapArgs, textObjectKey, types, selectionMode, pattern, isMatch )
"*******************************************************************************
"* PURPOSE: 
"   Define a complete set of mappings for inner and/or outer text objects that
"   support an optional [count] and select regions of lines which are defined by
"   contiguous lines that (don't) match a:pattern. 
"   The inner text object comprises all lines of the region itself, while the
"   outer text object also includes all adjacent lines above and below which do
"   not themselves belong to a region. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for operator-pending and visual mode which act upon /
"   select the text delimited by the begin and end patterns. 
"   If there are no <count> regions, a beep is emitted. 
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping. 
"   a:textObjectKey	Mapping key [sequence] after the mandatory i/a which
"			start the mapping for the text object. 
"   a:types		String containing 'i' for inner and 'a' for outer text
"			objects. 
"   a:selectionMode	Type of selection used between the patterns:
"			'v' for characterwise, 'V' for linewise, '<CTRL-V>' for
"			blockwise. Since regions are defined over full lines,
"			this should typically be 'V'. 
"   a:pattern	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it. 
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines. 
"
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    let l:scope = (a:mapArgs =~# '<buffer>' ? 'b:' : 's:')

    if a:types !~# '^[ai]\+$'
	throw "ASSERT: Type must consist of 'a' and/or 'i', but is: '" . a:types . "'" 
    endif

    " If only either an inner or outer text object is defined, the generated
    " function must include the type, so that it is possible to separately
    " define a text object of the other type (via a second invocation of this
    " function). If the same region definition is used for both inner and outer
    " text objects, no such distinction need to be made. 
    let l:typePrefix = (strlen(a:types) == 1 ? a:types : '')

    let l:functionToBeginName = printf('%sJumpToBegin_%s%s', l:scope, l:typePrefix, s:EscapeForFunctionName(a:textObjectKey))
    let l:functionToEndName   = printf('%sJumpToEnd_%s%s', l:scope, l:typePrefix, s:EscapeForFunctionName(a:textObjectKey))

    let l:regionFunction = "
    \	function! %s( count, isInner )\n
    \	    %s\n
    \	    let [l:pattern, l:isMatch, l:step, l:isToEndOfLine] = [%s, %d, %d, %d]\n
    \	    if a:isInner\n
    \		return CountJump#Region#JumpToRegionEnd(a:count, l:pattern, l:isMatch, l:step, l:isToEndOfLine)\n
    \	    else\n
    \		let l:isBackward = (l:step < 0)\n
    \		let l:regionEndPosition = CountJump#Region#JumpToRegionEnd(a:count, l:pattern, l:isMatch, l:step, 0)\n
    \		if l:regionEndPosition == [0, 0] || l:regionEndPosition[0] == (l:isBackward ? 1 : line('$'))\n
    \		    return l:regionEndPosition\n
    \		endif\n
    \		execute 'normal!' (l:isBackward ? 'k' : 'j')\n
    \		return CountJump#Region#JumpToRegionEnd(1, l:pattern, ! l:isMatch, l:step, l:isToEndOfLine)\n
    \	    endif\n
    \	endfunction"

    " The function-to-end starts at the beginning of the text object. For the
    " outer text object, this would make moving back into the region and then
    " beyond it complex. To instead, we use the knowledge that the
    " function-to-begin is executed first, and set the original cursor line
    " there, then start the function-to-end at that position. Since this may
    " also slightly speed up the search for the inner text object, we use it
    " unconditionally. 
    execute printf(l:regionFunction,
    \	l:functionToBeginName,
    \	'let s:originalLineNum = line(".")',
    \	string(a:pattern),
    \	a:isMatch,
    \	-1,
    \	0
    \)
    execute printf(l:regionFunction,
    \	l:functionToEndName,
    \	'execute s:originalLineNum',
    \	string(a:pattern),
    \	a:isMatch,
    \	1,
    \	1
    \)

    " For regions, the inner text object must include the text object's
    " boundaries = lines. 
    let l:types = substitute(a:types, 'i', 'I', 'g')
    return CountJump#TextObject#MakeWithJumpFunctions(a:mapArgs, a:textObjectKey, l:types, a:selectionMode, s:function(l:functionToBeginName), s:function(l:functionToEndName))
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
