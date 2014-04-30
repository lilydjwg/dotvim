" CountJump/Motion.vim: Create custom motions via repeated jumps (or searches).
"
" DEPENDENCIES:
"   - CountJump.vim, CountJump/Mappings.vim autoload scripts.
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.83.010	02-Jan-2014	Use more canonical way of invoking the Funcrefs
"				in
"				CountJump#Motion#MakeBracketMotionWithJumpFunctions();
"				this will then also work with passed String
"				function names.
"   1.81.009	16-Oct-2012	ENH: Add optional a:searchName argument to
"				CountJump#Motion#MakeBracketMotion() to make
"				searches wrap around when 'wrapscan' is set.
"				Custom jump functions can do this since version
"				1.70; now, this can also be utilized by motions
"				defined via a search pattern.
"   1.80.008	17-Sep-2012	FIX: Visual end pattern / jump to end with
"				'selection' set to "exclusive" also requires the
"				special additional treatment of moving one
"				right, like operator-pending mode. Always (for
"				all modes) pass uppercase a:mode in those cases,
"				not just for operator-pending mode.
"				BUG: Operator-pending motion with end pattern /
"				jump to end operates on one character too few
"				when moving to begin; must not pass uppercase
"				a:mode in the motions to begin. Add begin / end
"				flag to the datasets.
"   1.60.007	27-Mar-2012	ENH: When keys start with <Plug>, insert Forward
"				/ Backward instead of prepending [ / ].
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
"   a:keyAfterBracket	Mapping key [sequence] after the mandatory ] / [ which
"			start the mapping for a motion to the beginning of a
"			block.
"			When this starts with <Plug>, the key sequence is taken
"			as a template and a %s is replaced with "Forward" /
"			"Backward" instead of prepending ] / [. Through this,
"			plugins can define configurable mappings that not
"			necessarily start with ] / [.
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
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". Wrapping is determined by the 'wrapscan' setting.
"		    Optional; when not given or empty, searches never wrap.
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
    let l:searchName = (a:0 >= 2 ? a:2 : '')
    let l:wrapFlag = (empty(l:searchName) ? 'W' : '')

    if empty(a:keyAfterBracket) && empty(a:inverseKeyAfterBracket)
	let l:dataset = [
	\   [ 0, '[[', a:patternToBegin, 'b' . l:wrapFlag ],
	\   [ 0, ']]', a:patternToBegin, ''  . l:wrapFlag ],
	\   [ 1, '[]', a:patternToEnd,   'b' . l:wrapFlag . l:endMatch ],
	\   [ 1, '][', a:patternToEnd,   ''  . l:wrapFlag . l:endMatch ],
	\]
    else
	let l:dataset = []
	if ! empty(a:keyAfterBracket)
	    call add(l:dataset, [ 0, CountJump#Mappings#MakeMotionKey(0, a:keyAfterBracket), a:patternToBegin, 'b' . l:wrapFlag ])
	    call add(l:dataset, [ 0, CountJump#Mappings#MakeMotionKey(1, a:keyAfterBracket), a:patternToBegin, ''  . l:wrapFlag ])
	endif
	if ! empty(a:inverseKeyAfterBracket)
	    call add(l:dataset, [ 1, CountJump#Mappings#MakeMotionKey(0, a:inverseKeyAfterBracket), a:patternToEnd, 'b' . l:wrapFlag . l:endMatch ])
	    call add(l:dataset, [ 1, CountJump#Mappings#MakeMotionKey(1, a:inverseKeyAfterBracket), a:patternToEnd, ''  . l:wrapFlag . l:endMatch ])
	endif
    endif
    for l:mode in l:mapModes
	for l:data in l:dataset
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-U>call CountJump#CountJumpWithWrapMessage(%s, %s, %s, %s)<CR>",
	    \	    (l:mode ==# 'v' ? 'x' : l:mode),
	    \	    a:mapArgs,
	    \	    l:data[1],
	    \	    string(l:data[0] && a:isEndPatternToEnd ? toupper(l:mode) : l:mode),
	    \       string(l:searchName),
	    \	    string(l:data[2]),
	    \	    string(l:data[3])
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

function! s:AddTupleIfValue( list, tuple, value )
    if ! empty(a:value)
	call add(a:list, a:tuple + [a:value])
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
"			When this starts with <Plug>, the key sequence is taken
"			as a template and a %s is replaced with "Forward" /
"			"Backward" instead of prepending ] / [. Through this,
"			plugins can define configurable mappings that not
"			necessarily start with ] / [.
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
"		Uppercase letters indicate special additional treatment for end
"		jump to end.
"   All Funcrefs should position the cursor to the appropriate position in the
"   current window. See also CountJump#CountJumpFuncWithWrapMessage().
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
	call s:AddTupleIfValue(l:dataset, [0, '[['], a:JumpToBeginBackward)
	call s:AddTupleIfValue(l:dataset, [0, ']]'], a:JumpToBeginForward)
	call s:AddTupleIfValue(l:dataset, [1, '[]'], a:JumpToEndBackward)
	call s:AddTupleIfValue(l:dataset, [1, ']['], a:JumpToEndForward)
    else
	if ! empty(a:keyAfterBracket)
	    call s:AddTupleIfValue(l:dataset, [0, CountJump#Mappings#MakeMotionKey(0, a:keyAfterBracket)], a:JumpToBeginBackward)
	    call s:AddTupleIfValue(l:dataset, [0, CountJump#Mappings#MakeMotionKey(1, a:keyAfterBracket)], a:JumpToBeginForward)
	endif
	if ! empty(a:inverseKeyAfterBracket)
	    call s:AddTupleIfValue(l:dataset, [1, CountJump#Mappings#MakeMotionKey(0, a:inverseKeyAfterBracket)], a:JumpToEndBackward)
	    call s:AddTupleIfValue(l:dataset, [1, CountJump#Mappings#MakeMotionKey(1, a:inverseKeyAfterBracket)], a:JumpToEndForward)
	endif
    endif

    for l:mode in l:mapModes
	for l:data in l:dataset
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-u>call call(%s, [%s])<CR>",
	    \	    (l:mode ==# 'v' ? 'x' : l:mode),
	    \	    a:mapArgs,
	    \	    l:data[1],
	    \	    string(l:data[2]),
	    \	    string(l:data[0] && a:isEndJumpToEnd ? toupper(l:mode) : l:mode)
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
