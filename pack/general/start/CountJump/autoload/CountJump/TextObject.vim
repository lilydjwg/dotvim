" CountJump/TextObject.vim: Create custom text objects via repeated jumps (or searches).
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2009-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

"			Select text delimited by ???.
"ix			Select [count] text blocks delimited by ??? without the
"			outer delimiters.
"ax			Select [count] text blocks delimited by ??? including
"			the delimiters.
function! CountJump#TextObject#TextObjectWithJumpFunctions( mode, isInner, isExcludeBoundaries, selectionMode, JumpToBegin, JumpToEnd )
"*******************************************************************************
"* PURPOSE:
"   Creates a visual selection (in a:selectionMode) around the <count>'th
"   inner / outer text object delimited by the a:JumpToBegin and a:JumpToEnd
"   functions.
"   If there is no match, or the jump is not around the cursor position, the
"   failure to select the text object is indicated via a beep. In visual mode,
"   the selection is maintained then (using a:selectionMode). the built-in text
"   objects work in the same way.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Creates / modifies visual selection.
"
"* INPUTS:
"   a:mode  Mode for the text object; either 'o' (operator-pending) or 'v'
"	    (visual).
"   a:isInner	Flag whether this is an "inner" text object (i.e. it excludes
"		the boundaries, or an "outer" one. This variable is passed to
"		the a:JumpToBegin and a:JumpToEnd functions.
"   a:isExcludeBoundaries   Flag whether the matching boundaries should not be
"			    part of the text object. Except for special cases,
"			    the value should correspond with a:isInner.
"   a:selectionMode Specifies how the text object selects text; either 'v', 'V'
"		    or "\<C-V>".
"   a:JumpToBegin   Funcref that jumps to the beginning of the text object.
"		    The function must take a count (always 1 here) and the
"		    a:isInner flag (which determines whether the jump should be
"		    to the end of the boundary text).
"		    The function is invoked at the cursor position where the
"		    text object was requested.
"   a:JumpToEnd	    Funcref that jumps to the end of the text object.
"		    The function must take a count and the a:isInner flag.
"		    The function is invoked after the call to a:JumpToBegin,
"		    with the cursor located at the beginning of the text object.
"
"		    Both Funcrefs must return a list [lnum, col], like
"		    searchpos(). This should be the jump position (or [0, 0] if
"		    a jump wasn't possible). Normally, this should correspond to
"		    the cursor position set by the jump function. However, for
"		    an inner jump, this could also be the outer jump position.
"		    This function will use this position for the check that the
"		    jump is around the cursor position; if the returned position
"		    is the outer jump position, an inner text object will allow
"		    selection even when the cursor is on the boundary text (like
"		    the built-in text objects).
"* RETURN VALUES:
"   None.
"
"* KNOWN PROBLEMS:
"   At the beginning and end of the buffer, the inner text objects may select
"   one character / line less than it should, because the compensating motions
"   are always executed, but the jump cannot position the cursor "outside" the
"   buffer (i.e. before the first / after the last line).
"*******************************************************************************
    let l:count = v:count1
    let l:isExclusive = (&selection ==# 'exclusive')
    let l:isLinewise = (a:selectionMode ==# 'V')
    let l:save_view = winsaveview()
    let [l:cursorLine, l:cursorCol] = [line('.'), col('.')]
    let l:isSelected = 0
    let g:CountJump_TextObjectContext = {}

    let l:save_whichwrap = &whichwrap
    let l:save_virtualedit = &virtualedit
    set virtualedit=onemore " Need to move beyond the current line for proper selection of an end position at the end of the line when 'selection' is "exclusive"; otherwise, the "l" motion would select the newline, too.
    set whichwrap+=h,l
    try
	let l:beginPosition = call(a:JumpToBegin, [1, a:isInner])
"****D echomsg '**** begin' string(l:beginPosition) 'cursor:' string(getpos('.'))
	if l:beginPosition != [0, 0]
	    if a:isExcludeBoundaries
		if l:isLinewise
		    silent! normal! j0
		else
		    silent! normal! l
		endif
	    endif
	    let l:beginPosition = getpos('.')

"****D echomsg '**** end search from' string(l:beginPosition)
	    let l:endPosition = call(a:JumpToEnd, [l:count, a:isInner])
"****D echomsg '**** end  ' string(l:endPosition) 'cursor:' string(getpos('.'))
	    if l:endPosition == [0, 0] ||
	    \	l:endPosition[0] < l:cursorLine ||
	    \	(! l:isLinewise && l:endPosition[0] == l:cursorLine && l:endPosition[1] < l:cursorCol)
		" The end has not been found or is located before the original
		" cursor position; abort. (And in the latter case, beep; in the
		" former case, the jump function has done that already.)
		" For the check, the returned jump position is used, not the
		" current cursor position. This enables the jump functions to
		" return the outer jump position for an inner jump, and allows
		" to select an inner text object when the cursor is on the
		" boundary text.
		" Note: For linewise selections, the returned column doesn't matter.
		" FIXME: For blockwise selections, the original cursor screen
		" column should be inside the selection. However, this requires
		" translation of the byte-indices used here into screen columns.
		"
		if l:endPosition != [0, 0]
		    " We need to cancel visual mode in case an end has been
		    " found. This is done via <C-\><C-n>.
		    " When the end is located before the original cursor
		    " position, beep. In the other case, when the end has not
		    " been found, the jump function has done that already.
		    execute "normal! \<C-\>\<C-n>\<Esc>"
		endif

		call winrestview(l:save_view)
	    else
		if l:isLinewise
		    if a:isExcludeBoundaries
			silent! normal! k0
		    endif
		else
		    if ! l:isExclusive && a:isExcludeBoundaries
			silent! normal! h
		    elseif l:isExclusive && ! a:isExcludeBoundaries
			silent! normal! l
		    endif
		endif

		let l:endPosition = getpos('.')
"****D echomsg '**** text object from' string(l:beginPosition) 'to' string(l:endPosition)
		" When the end position is before the begin position, that's not
		" a valid selection.
		if ingo#pos#IsBefore(l:endPosition[1:2], l:beginPosition[1:2])
		    execute "normal! \<C-\>\<C-n>\<Esc>"

		    call winrestview(l:save_view)
		else
		    " Now that we know that both begin and end positions exist,
		    " create the visual selection using the corrected positions.
		    let l:isSelected = 1

		    if l:isLinewise
			" For linewise selections, always position the cursor at
			" the start of the end line. This is consistent with the
			" built-in text objects (e.g. |ap|), and avoids that the
			" window is horizontally scrolled to the right.
			let l:beginPosition[2] = 1
			let l:endPosition[2] = 1
		    endif

		    call setpos('.', l:beginPosition)
		    execute 'normal!' a:selectionMode
		    call setpos('.', l:endPosition)
		endif
	    endif
	endif

	if ! l:isSelected && a:mode ==# 'v'
	    " Re-enter the previous visual mode if no text object could be
	    " selected.
	    " This must not be done in operator-pending mode, or the
	    " operator would work on the selection!
	    normal! gv
	endif
    finally
	unlet! g:CountJump_TextObjectContext
	let &virtualedit = l:save_virtualedit
	let &whichwrap = l:save_whichwrap
    endtry
endfunction
function! CountJump#TextObject#MakeWithJumpFunctions( mapArgs, textObjectKey, types, selectionMode, JumpToBegin, JumpToEnd )
"*******************************************************************************
"* PURPOSE:
"   Define a complete set of mappings for inner and/or outer text objects that
"   support an optional [count] and are driven by two functions that jump to the
"   beginning and end of a block.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for operator-pending and visual mode which act upon /
"   select the text delimited by the locations where the two functions jump to.
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping.
"   a:textObjectKey	Mapping key [sequence] after the mandatory i/a which
"			start the mapping for the text object.
"			When this starts with <Plug>, the key sequence is taken
"			as a template and a %s is replaced with "Inner" /
"			"Outer" instead of prepending i / a. Through this,
"			plugins can define configurable text objects that not
"			necessarily start with i / a.
"   a:types		String containing 'i' for inner and 'a' for outer text
"			objects.
"			Use 'I' if you want the inner jump _include_ the text
"			object's boundaries, and 'A' if you want the outer jump
"			to _exclude_ the boundaries. This is only necessary in
"			special cases.
"   a:selectionMode	Type of selection used between the patterns:
"			'v' for characterwise, 'V' for linewise, '<CTRL-V>' for
"			blockwise.
"			In linewise mode, the inner text objects do not contain
"			the complete lines matching the pattern.
"   a:JumpToBegin	Function which is invoked to jump to the begin of the
"			block.
"			The function is invoked at the cursor position where the
"			text object was requested.
"   a:JumpToEnd		Function which is invoked to jump to the end of the
"			block.
"			The function is invoked after the call to a:JumpToBegin,
"			with the cursor located at the beginning of the text object.
"   The jump functions must take two arguments:
"	JumpToBegin( count, isInner )
"	JumpToEnd( count, isInner )
"	a:count	Number of blocks to jump to.
"	a:isInner	Flag whether the jump should be to the inner or outer
"			delimiter of the block.
"   Both Funcrefs must return a list [lnum, col], like searchpos(). This should
"   be the jump position (or [0, 0] if a jump wasn't possible).
"   They should position the cursor to the appropriate position in the current
"   window.
"
"* RETURN VALUES:
"   None.
"*******************************************************************************
    for l:type in split(a:types, '\zs')
	if l:type ==# 'a'
	    let [l:isInner, l:isExcludeBoundaries] = [0, 0]
	elseif l:type ==# 'A'
	    let [l:isInner, l:isExcludeBoundaries] = [0, 1]
	elseif l:type ==# 'i'
	    let [l:isInner, l:isExcludeBoundaries] = [1, 1]
	elseif l:type ==# 'I'
	    let [l:isInner, l:isExcludeBoundaries] = [1, 0]
	else
	    throw 'ASSERT: Unknown type ' . string(l:type) . ' in ' . string(a:types)
	endif
	for l:mode in ['o', 'v']
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-u>if ! CountJump#%sMapping('CountJump#TextObject#TextObjectWithJumpFunctions', %s)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>",
	    \       (l:mode ==# 'v' ? 'x' : l:mode),
	    \       a:mapArgs,
	    \       CountJump#Mappings#MakeTextObjectKey(tolower(l:type), a:textObjectKey),
	    \       (l:mode ==# 'o' ? 'O' : ''),
	    \       string([
	    \           l:mode,
	    \           l:isInner,
	    \           l:isExcludeBoundaries,
	    \           a:selectionMode,
	    \           a:JumpToBegin,
	    \           a:JumpToEnd
	    \       ])
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

function! s:function(name)
    return function(substitute(a:name, '^\Cs:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'),''))
endfunction
function! CountJump#TextObject#MakeWithCountSearch( mapArgs, textObjectKey, types, selectionMode, patternToBegin, patternToEnd )
"*******************************************************************************
"* PURPOSE:
"   Define a complete set of mappings for inner and/or outer text objects that
"   support an optional [count] and are driven by search patterns for the
"   beginning and end of a block.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for operator-pending and visual mode which act upon /
"   select the text delimited by the begin and end patterns.
"   If the pattern doesn't match (<count> times), a beep is emitted.
"
"* INPUTS:
"   a:mapArgs	Arguments to the :map command, like '<buffer>' for a
"		buffer-local mapping.
"   a:textObjectKey	Mapping key [sequence] after the mandatory i/a which
"			start the mapping for the text object.
"			When this starts with <Plug>, the key sequence is taken
"			as a template and a %s is replaced with "Inner" /
"			"Outer" instead of prepending i / a. Through this,
"			plugins can define configurable text objects that not
"			necessarily start with i / a.
"   a:types		String containing 'i' for inner and 'a' for outer text
"			objects.
"   a:selectionMode	Type of selection used between the patterns:
"			'v' for characterwise, 'V' for linewise, '<CTRL-V>' for
"			blockwise.
"			In linewise mode, the inner text objects do not contain
"			the complete lines matching the pattern.
"   a:patternToBegin	Search pattern to locate the beginning of a block.
"   a:patternToEnd	Search pattern to locate the end of a block.
"			Note: The patterns should always match a non-empty
"			boundary text; zero-width or matches at the end of the
"			buffer are problematic.
"			Note: Inner text objects first make an outer jump, then
"			go to the other (inner) side of the boundary text in
"			order to make a selection when the cursor is on the
"			boundary text, so fancy patterns that take the current
"			position into account are problematic, too.
"			If this simple matching doesn't work for you, define
"			your own jump function and graduate to the more powerful
"			CountJump#TextObject#MakeWithJumpFunctions() function
"			instead.
"* RETURN VALUES:
"   None.
"*******************************************************************************
    if a:types !~# '^[ai]\+$'
	throw "ASSERT: Type must consist of 'a' and/or 'i', but is: '" . a:types . "'"
    endif

    let l:scope = (a:mapArgs =~# '<buffer>' ? 's:B' . bufnr('') : 's:')

    " If only either an inner or outer text object is defined, the generated
    " function must include the type, so that it is possible to separately
    " define a text object of the other type (via a second invocation of this
    " function). If the same pattern to begin / end can be used for both inner
    " and outer text objects, no such distinction need to be made.
    let l:typePrefix = (strlen(a:types) == 1 ? a:types : '')
    let l:functionName = CountJump#Mappings#EscapeForFunctionName(CountJump#Mappings#MakeTextObjectKey(l:typePrefix, a:textObjectKey))

    let l:functionToBeginName = printf('%sJumpToBegin_%s', l:scope, l:functionName)
    let l:functionToEndName   = printf('%sJumpToEnd_%s',   l:scope, l:functionName)

    " In case of an inner jump, we first make an outer jump, store the position,
    " then go to the other (inner) side of the boundary text, and return the
    " outer jump position. This allows the text object to select an inner text
    " object when the cursor is on the boundary text.
    let l:searchFunction = "
    \	function! %s( count, isInner )\n
    \	    if a:isInner\n
    \		let l:matchPos = CountJump#CountSearch(a:count, [%s, %s])\n
    \		if l:matchPos != [0, 0]\n
    \		    call CountJump#CountSearch(1, [%s, %s])\n
    \		endif\n
    \		return l:matchPos\n
    \	    else\n
    \		return CountJump#CountSearch(a:count, [%s, %s])\n
    \	    endif\n
    \	endfunction"
    execute printf(l:searchFunction,
    \	l:functionToBeginName,
    \	string(a:patternToBegin), string('bcW'),
    \	string(a:patternToBegin), string('ceW'),
    \	string(a:patternToBegin), string('bcW')
    \)
    execute printf(l:searchFunction,
    \	l:functionToEndName,
    \	string(a:patternToEnd), string('ceW'),
    \	string(a:patternToEnd), string('bcW'),
    \	string(a:patternToEnd), string('eW')
    \)
    " Note: For the outer jump to end, a:patternToEnd must not match at the
    " current cursor position (no 'c' flag to search()). This allows to handle
    " outer text objects that are delimited by the same, single character.

    return CountJump#TextObject#MakeWithJumpFunctions(a:mapArgs, a:textObjectKey, a:types, a:selectionMode, s:function(l:functionToBeginName), s:function(l:functionToEndName))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
