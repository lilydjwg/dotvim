" CountJump#Region#Motion.vim: Create custom motions via jumps over matching
" lines. 
"
" DEPENDENCIES:
"   - CountJump.vim, CountJump/Region.vim autoload scripts. 
"
" Copyright: (C) 2010 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.30.002	19-Dec-2010	Added a:isToEndOfLine argument to
"				CountJump#Region#JumpToNextRegion(), to be used
"				in operator-pending and visual modes in order to
"				jump to the end of the matching line (for the ][
"				motion only). In that case, also using special
"				'O' mode argument for CountJump#JumpFunc() to
"				include the last character, too. 
"	001	18-Dec-2010	file creation

"			Move around ???
"]x, ]]			Go to [count] next start of ???. 
"]X, ][			Go to [count] next end of ???. 
"[x, [[			Go to [count] previous start of ???. 
"[X, []			Go to [count] previous end of ???. 

function! CountJump#Region#Motion#MakeBracketMotion( mapArgs, keyAfterBracket, inverseKeyAfterBracket, pattern, isMatch, ... )
"*******************************************************************************
"* PURPOSE:
"   Define a complete set of mappings for a [x / ]x motion (e.g. like the
"   built-in ]m "Jump to start of next method") that support an optional [count]
"   and jump over regions of lines which are defined by contiguous lines that
"   (don't) match a:pattern. 
"   The mappings work in normal mode (jump), visual mode (expand selection) and
"   operator-pending mode (execute operator). 

"   Normally, it will jump to the column of the first match (typically, that is
"   column 1, always so for non-matches). But for the ]X or ][ mapping, it will
"   include the entire line in operator-pending and visual mode; operating over
"   / selecting the entire region is typically what the user expects. 
"   In visual mode, the mode will NOT be changed to linewise, though that, due
"   to the linewise definition of a region, is usually the best mode to use the
"   mappings in. Likewise, an operator will only work from the cursor position,
"   not the entire line the cursor was on. If you want to force linewise mode,
"   either go into linewise visual mode first or try the corresponding text
"   object (if one exists); text objects DO usually switch the selection mode
"   into what's more appropriate for them. (Compare the behavior of the built-in
"   paragraph motion |}| vs. the "a paragraph" text object |ap|.) 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"
"* EFFECTS / POSTCONDITIONS:
"   Creates mappings for normal, visual and operator-pending mode: 
"	Normal mode: Jumps to the <count>th region. 
"	Visual mode: Extends the selection to the <count>th region. 
"	Operator-pending mode: Applies the operator to the covered text. 
"	If there aren't <count> more regions, a beep is emitted. 
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
"   a:pattern	Regular expression that defines the region, i.e. must (not)
"		match in all lines belonging to it. 
"   a:isMatch	Flag whether to search matching (vs. non-matching) lines. 
"   a:mapModes		Optional string containing 'n', 'o' and/or 'v',
"			representing the modes for which mappings should be
"			created. Defaults to all modes. 
"
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    let l:mapModes = split((a:0 ? a:1 : 'nov'), '\zs')

    let l:dataset = [] " List of [ mapping keys, step, isAcrossRegion, isToEndOfLine ]
    if empty(a:keyAfterBracket) && empty(a:inverseKeyAfterBracket)
	call add(l:dataset, ['[[', -1, 1, 0])
	call add(l:dataset, [']]', 1, 0, 0])
	call add(l:dataset, ['[]', -1, 0, 0])
	call add(l:dataset, ['][', 1, 1, 1])
    else
	if ! empty(a:keyAfterBracket)
	    call add(l:dataset, ['[' . a:keyAfterBracket, -1, 1, 0])
	    call add(l:dataset, [']' . a:keyAfterBracket, 1, 0, 0])
	endif
	if ! empty(a:inverseKeyAfterBracket)
	    call add(l:dataset, ['[' . a:inverseKeyAfterBracket, -1, 0, 0])
	    call add(l:dataset, [']' . a:inverseKeyAfterBracket, 1, 1, 1])
	endif
    endif

    for l:mode in l:mapModes
	for l:data in l:dataset
	    let l:useToEndOfLine = (l:mode ==# 'n' ? 0 : l:data[3])
	    execute escape(
	    \   printf("%snoremap <silent> %s %s :<C-U>call CountJump#JumpFunc(%s, 'CountJump#Region#JumpToNextRegion', %s, %d, %d, %d, %d)<CR>",
	    \	    (l:mode ==# 'v' ? 'x' : l:mode),
	    \	    a:mapArgs,
	    \	    l:data[0],
	    \	    string(l:mode ==# 'o' && l:useToEndOfLine ? 'O' : l:mode),
	    \	    string(a:pattern),
	    \	    a:isMatch,
	    \	    l:data[1],
	    \	    l:data[2],
	    \	    l:useToEndOfLine
	    \   ), '|'
	    \)
	endfor
    endfor
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
