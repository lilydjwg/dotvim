" CountJump#Motion.vim: Create custom motions via repeated jumps (or searches). 
"
" DEPENDENCIES:
"   - CountJump.vim autoload script. 
"
" Copyright: (C) 2009-2010 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.30.006	19-Dec-2010	Clarified interface of jump function arguments;
"				no need to return jump position here. 
"   1.22.005	06-Aug-2010	No more motion mappings for select mode; as the
"				mappings start with a printable character, no
"				select-mode mapping should be defined. 
"   1.20.004	30-Jul-2010	ENH: a:keyAfterBracket and
"				a:inverseKeyAfterBracket can now be empty, the
"				resulting mappings are then omitted. 
"				Likewise, any jump function can be empty in
"				CountJump#Motion#MakeBracketMotionWithJumpFunctions(). 
"   1.20.003	21-Jul-2010	With the added
"				CountJump#Motion#MakeBracketMotionWithJumpFunctions()
"				motions can be defined via jump functions,
"				similar to how text objects can be defined. This
"				is a generalization of
"				CountJump#Motion#MakeBracketMotion(), but the
"				latter isn't now implemented through the
"				generalization to avoid overhead and because the
"				similarities are not as strong as with the text
"				objects. 
"   1.00.002	22-Jun-2010	Added missing :omaps for operator-pending mode. 
"				Replaced s:Escape() with string() and simplified
"				building of l:dataset. 
"				Added special mode 'O' to indicate
"				operator-pending mapping with
"				a:isEndPatternToEnd. 
"				Allowing to specify map modes via optional
"				argument to CountJump#Motion#MakeBracketMotion()
"				to allow to skip or use different patterns for
"				some modes. 
"	001	14-Feb-2009	Renamed from 'custommotion.vim' to
"				'CountJump.vim' and split off motion and
"				text object parts. 
"				file creation

let s:save_cpo = &cpo
set cpo&vim

"			Move around ???
"]x, ]]			Go to [count] next start of ???. 
"]X, ][			Go to [count] next end of ???. 
"[x, [[			Go to [count] previous start of ???. 
"[X, []			Go to [count] previous end of ???. 
"
" This mapping scheme is extracted from $VIMRUNTIME/ftplugin/vim.vim. It
" enhances the original mappings so that a [count] can be specified, and folds
" at the found search position are opened. 
function! CountJump#Motion#MakeBracketMotion( mapArgs, keyAfterBracket, inverseKeyAfterBracket, patternToBegin, patternToEnd, isEndPatternToEnd, ... )
"*******************************************************************************
"* PURPOSE:
"   Define a complete set of mappings for a [x / ]x motion (e.g. like the
"   built-in ]m "Jump to start of next method") that support an optional [count]
"   and are driven by search patterns for the beginning and end of a block. 
"   The mappings work in normal mode (jump), visual mode (expand selection) and
"   operator-pending mode (execute operator). 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for normal, visual and operator-pending mode: 
"	Normal mode: Jumps to the <count>th occurrence. 
"	Visual mode: Extends the selection to the <count>th occurrence. 
"	Operator-pending mode: Applies the operator to the covered text. 
"	If the pattern doesn't match (<count> times), a beep is emitted. 
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping. 
"   a:keyAfterBracket	Mapping key [sequence] after the mandatory ]/[ which
"			start the mapping for a motion to the beginning of a
"			block. 
"			Can be empty; the resulting mappings are then omitted. 
"   a:inverseKeyAfterBracket	Likewise, but for the motions to the end of a
"				block. Usually the uppercased version of
"				a:keyAfterBracket. 
"				Can be empty; the resulting mappings are then
"				omitted. 
"   If both a:keyAfterBracket and a:inverseKeyAfterBracket are empty, the
"   default [[ and ]] mappings are overwritten. (Note that this is different
"   from passing ']' and '[', respectively, because the back motions are
"   swapped.) 
"   a:patternToBegin	Search pattern to locate the beginning of a block. 
"   a:patternToEnd	Search pattern to locate the end of a block. 
"   a:isEndPatternToEnd	Flag that specifies whether a jump to the end of a block
"			will be to the end of the match. This makes it easier to
"			write an end pattern for characterwise motions (like
"			e.g. a block delimited by {{{ and }}}). 
"			Linewise motions best not set this flag, so that the
"			end match positions the cursor in the first column. 
"   a:mapModes		Optional string containing 'n', 'o' and/or 'v',
"			representing the modes for which mappings should be
"			created. Defaults to all modes. 
"
"* NOTES:
"   - If your motion is linewise, the patterns should have the start of match
"     at the first column. This results in the expected behavior in normal mode,
"     and in characterwise visual mode selects up to that line, and in (more
"     likely) linewise visual mode includes the complete end line. 
"   - Depending on the 'selection' setting, the first matched character is
"     either included or excluded in a characterwise visual selection. 
"
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    let l:endMatch = (a:isEndPatternToEnd ? 'e' : '')
    let l:mapModes = split((a:0 ? a:1 : 'nov'), '\zs')

    if empty(a:keyAfterBracket) && empty(a:inverseKeyAfterBracket)
	let l:dataset = [
	\   [ '[[', a:patternToBegin, 'bW' ],
	\   [ ']]', a:patternToBegin, 'W' ],
	\   [ '[]', a:patternToEnd, 'bW' . l:endMatch ],
	\   [ '][', a:patternToEnd, 'W' . l:endMatch ],
	\]
    else
	let l:dataset = []
	if ! empty(a:keyAfterBracket)
	    call add(l:dataset, [ '[' . a:keyAfterBracket, a:patternToBegin, 'bW' ])
	    call add(l:dataset, [ ']' . a:keyAfterBracket, a:patternToBegin, 'W' ])
	endif
	if ! empty(a:inverseKeyAfterBracket)
	    call add(l:dataset, [ '[' . a:inverseKeyAfterBracket, a:patternToEnd, 'bW' . l:endMatch ])
	    call add(l:dataset, [ ']' . a:inverseKeyAfterBracket, a:patternToEnd, 'W' . l:endMatch ])
	endif
    endif
    for l:mode in l:mapModes
	for l:data in l:dataset
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-U>call CountJump#CountJump(%s, %s, %s)<CR>",
	    \	    (l:mode ==# 'v' ? 'x' : l:mode),
	    \	    a:mapArgs,
	    \	    l:data[0],
	    \	    string((l:mode ==# 'o' && a:isEndPatternToEnd) ? 'O' : l:mode),
	    \	    string(l:data[1]),
	    \	    string(l:data[2])
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

function! s:AddTupleIfValue( list, key, value )
    if ! empty(a:value)
	call add(a:list, [a:key, a:value])
    endif
endfunction
function! CountJump#Motion#MakeBracketMotionWithJumpFunctions( mapArgs, keyAfterBracket, inverseKeyAfterBracket, JumpToBeginForward, JumpToBeginBackward, JumpToEndForward, JumpToEndBackward, isEndJumpToEnd, ... )
"*******************************************************************************
"* PURPOSE:
"   Define a complete set of mappings for a [x / ]x motion (e.g. like the
"   built-in ]m "Jump to start of next method") that support an optional [count]
"   and are driven by two functions that jump to the beginning and end of a block. 
"   The mappings work in normal mode (jump), visual mode (expand selection) and
"   operator-pending mode (execute operator). 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for normal, visual and operator-pending mode: 
"	Normal mode: Jumps to the <count>th occurrence. 
"	Visual mode: Extends the selection to the <count>th occurrence. 
"	Operator-pending mode: Applies the operator to the covered text. 
"	If the pattern doesn't match (<count> times), a beep is emitted. 
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping. 
"   a:keyAfterBracket	Mapping key [sequence] after the mandatory ]/[ which
"			start the mapping for a motion to the beginning of a
"			block. 
"			Can be empty; the resulting mappings are then omitted. 
"   a:inverseKeyAfterBracket	Likewise, but for the motions to the end of a
"				block. Usually the uppercased version of
"				a:keyAfterBracket. 
"				Can be empty; the resulting mappings are then
"				omitted. 
"   If both a:keyAfterBracket and a:inverseKeyAfterBracket are empty, the
"   default [[ and ]] mappings are overwritten. (Note that this is different
"   from passing ']' and '[', respectively, because the back motions are
"   swapped.) 
"   a:JumpToBeginForward	Function which is invoked to jump to the begin of the
"				block in forward direction. 
"   a:JumpToBeginBackward	Function which is invoked to jump to the begin of the
"				block in backward direction. 
"   a:JumpToEndForward		Function which is invoked to jump to the end of the
"				block in forward direction. 
"   a:JumpToEndBackward		Function which is invoked to jump to the end of the
"				block in backward direction. 
"   The jump functions must take one argument:
"	JumpTo...( mode )
"	a:mode  Mode in which the search is invoked. Either 'n', 'v' or 'o'. 
"		With 'O': Special additional treatment for operator-pending mode
"		with a pattern to end. 
"   All funcrefs should position the cursor to the appropriate position in the
"   current window. 
"   If no jump function is passed, the corresponding mappings are omitted. 

"   a:isEndJumpToEnd	Flag that specifies whether a jump to the end of a block
"			will be to the last character of the block delimiter
"			(vs. to the first character of the block delimiter or
"			completely after the block delimiter). 
"   a:mapModes		Optional string containing 'n', 'o' and/or 'v',
"			representing the modes for which mappings should be
"			created. Defaults to all modes. 
"
"* NOTES:
"   - If your motion is linewise, the jump functions should jump to the first
"     column. This results in the expected behavior in normal mode, and in
"     characterwise visual mode selects up to that line, and in (more likely)
"     linewise visual mode includes the complete end line. 
"
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    let l:mapModes = split((a:0 ? a:1 : 'nov'), '\zs')

    let l:dataset = []
    if empty(a:keyAfterBracket) && empty(a:inverseKeyAfterBracket)
	call s:AddTupleIfValue(l:dataset, '[[', a:JumpToBeginBackward)
	call s:AddTupleIfValue(l:dataset, ']]', a:JumpToBeginForward)
	call s:AddTupleIfValue(l:dataset, '[]', a:JumpToEndBackward)
	call s:AddTupleIfValue(l:dataset, '][', a:JumpToEndForward)
    else
	if ! empty(a:keyAfterBracket)
	    call s:AddTupleIfValue(l:dataset, '[' . a:keyAfterBracket, a:JumpToBeginBackward)
	    call s:AddTupleIfValue(l:dataset, ']' . a:keyAfterBracket, a:JumpToBeginForward)
	endif
	if ! empty(a:inverseKeyAfterBracket)
	    call s:AddTupleIfValue(l:dataset, '[' . a:inverseKeyAfterBracket, a:JumpToEndBackward)
	    call s:AddTupleIfValue(l:dataset, ']' . a:inverseKeyAfterBracket, a:JumpToEndForward)
	endif
    endif

    for l:mode in l:mapModes
	for l:data in l:dataset
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-U>call %s(%s)<CR>",
	    \	    (l:mode ==# 'v' ? 'x' : l:mode),
	    \	    a:mapArgs,
	    \	    l:data[0],
	    \	    string(l:data[1]),
	    \	    string((l:mode ==# 'o' && a:isEndJumpToEnd) ? 'O' : l:mode)
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
