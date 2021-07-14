" ingo/text/frompattern.vim: Functions to get matches from the current buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.004	06-May-2015	Add ingo#text#frompattern#GetAroundHere(),
"				inspired by
"				http://stackoverflow.com/questions/30073662/vim-copy-match-with-cursor-position-atom-to-local-variable
"   1.024.003	17-Apr-2015	ingo#text#frompattern#GetHere(): Do not move the
"				cursor (to the end of the matched pattern); this
"				is unexpected and can be easily avoided.
"   1.014.002	27-Sep-2013	Add ingo#text#frompattern#GetHere().
"   1.012.001	03-Sep-2013	file creation

function! ingo#text#frompattern#GetHere( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract the match of a:pattern starting from the current cursor position.
"* SEE ALSO:
"   - ingo#area#frompattern#GetHere() returns the positions, not the match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:lastLine      End line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"* RETURN VALUES:
"   Matched text, or empty string.
"******************************************************************************
    let l:startPos = getpos('.')[1:2]
    let l:endPos = searchpos(a:pattern, 'cenW', (a:0 ? a:1 : line('.')))
    if l:endPos == [0, 0]
	return ''
    endif
    return ingo#text#Get(l:startPos, l:endPos)
endfunction
function! ingo#text#frompattern#GetAroundHere( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract the match of a:pattern starting the match from the current cursor
"   position, but (unlike ingo#text#frompattern#GetHere()), also include matched
"   characters _before_ the current position.
"* SEE ALSO:
"   - ingo#area#frompattern#GetAroundHere() returns the positions, not the match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:lastLine      End line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"   a:firstLine     First line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"* RETURN VALUES:
"   Matched text, or empty string.
"******************************************************************************
    let l:startPos = searchpos(a:pattern, 'bcnW', (a:0 >= 2 ? a:2 : line('.')))
    if l:startPos == [0, 0]
	return ''
    endif
    let l:endPos = searchpos(a:pattern, 'cenW', (a:0 ? a:1 : line('.')))
    if l:endPos == [0, 0]
	return ''
    endif
    return ingo#text#Get(l:startPos, l:endPos)
endfunction

function! ingo#text#frompattern#GetCurrent( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract the match of a:pattern that includes the current cursor position
"   inside. This is a stronger condition than
"   ingo#text#frompattern#GetAroundHere(), which may include text that matches
"   before and after the current position, but does not neccessarily include the
"   cursor position itself. So this function can be used when it's difficult to
"   include a cursor position assertion (\%#) inside a:pattern.
"* SEE ALSO:
"   - ingo#area#frompattern#GetCurrent() returns the positions, not the match.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:options.returnValueOnNoSelection
"		    Optional return value if there's no match. If omitted, the
"		    empty string will be returned.
"   a:options.currentPos
"		    Optional base position.
"   a:options.firstLnum
"		    Optional first line number to search for the start of the
"		    pattern. Defaults to the current line.
"   a:options.lastLnum
"		    Optional end line number to search for the start of the
"		    pattern. Defaults to the current line.
"* RETURN VALUES:
"   Matched text, or empty string.
"******************************************************************************
    let l:arguments = [a:pattern]
    let l:returnValueOnNoSelection = ''
    if a:0 >= 1
	let l:options = copy(a:1)
	if has_key(l:options, 'returnValueOnNoSelection')
	    let l:returnValueOnNoSelection = l:options.returnValueOnNoSelection
	    unlet l:options.returnValueOnNoSelection
	endif
	call add(l:arguments, l:options)
    endif

    let [l:startPos, l:endPos] = call('ingo#area#frompattern#GetCurrent', l:arguments)
    return (l:startPos == [0, 0] ? l:returnValueOnNoSelection : ingo#text#Get(l:startPos, l:endPos))
endfunction


function! ingo#text#frompattern#Get( firstLine, lastLine, pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract all non-overlapping matches of a:pattern in the a:firstLine,
"   a:lastLine range and return them (optionally a submatch / replacement, or
"   only first or unique matches) as a List.
"* SEE ALSO:
"   - ingo#str#frompattern#Get() extracts matches from a string / List of lines
"     instead of the current buffer.
"   - ingo#area#frompattern#Get() returns the positions, not the matches.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:firstLine     Start line number to search.
"   a:lastLine      End line number to search.
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:replacement   Optional replacement substitute(). When not empty, each
"		    match is processed through substitute() with a:pattern.
"		    When a:pattern cannot be used (e.g. because it references
"		    cursor or buffer position via special atoms like \%# and
"		    therefore doesn't work standalone), you can also pass a
"		    [replPattern, replacement] tuple, which will then be
"		    globally applied to the match.
"   a:isOnlyFirstMatch  Optional flag whether to include only the first match in
"                       every line. By default, all matches are returned.
"   a:isUnique          Optional flag whether duplicate matches (actually unique
"                       replacements if given) are omitted from the result. When
"                       set, the result will consist of unique matches.
"   a:Predicate	    Optional function reference that is called on each match;
"		    takes a context object as argument and returns whether the
"		    match should be included. Or pass an empty value to accept
"		    all locations.
"		    The context object has the following attributes:
"			match:      current matched text
"			matchStart: [lnum, col] of the match start
"			matchEnd:   [lnum, col] of the match end (this is also
"				    the cursor position)
"			replacement:current replacement text (if passed, else
"				    equal to match)
"			matchCount: number of current (unique) match of {pattern}
"			acceptedCount:
"				    number of matches already accepted by the
"				    predicate
"			n: number / flag (0 / false)
"			m: number / flag (1 / true)
"			l: empty List []
"			d: empty Dictionary {}
"			s: empty String ""
"* RETURN VALUES:
"   List of (optionally replaced) matches, or empty List when no matches.
"******************************************************************************
    let l:replacement = (a:0 >= 1 ? a:1 : '')
    let l:isOnlyFirstMatch = (a:0 >= 2 ? a:2 : 0)
    let l:isUnique = (a:0 >= 3 ? a:3 : 0)
    let l:Predicate = (a:0 >= 4 ? a:4 : 0)
    let l:context = {'match': '', 'replacement': '', 'matchCount': 0, 'acceptedCount': 0, 'n': 0, 'm': 1, 'l': [], 'd': {}, 's': ''}

    let l:save_view = winsaveview()
	let l:matches = []
	call cursor(a:firstLine, 1)
	let l:isFirst = 1
	while 1
	    let l:startPos = searchpos(a:pattern, (l:isFirst ? 'c' : '') . 'W', a:lastLine)
	    let l:isFirst = 0
	    if l:startPos == [0, 0] | break | endif
	    let l:endPos = searchpos(a:pattern, 'ceW', a:lastLine)
	    if l:endPos == [0, 0] | break | endif
	    let l:match = ingo#text#Get(l:startPos, l:endPos)
	    let l:originalMatch = l:match

	    if ! empty(l:replacement)
		if type(l:replacement) == type([])
		    let l:match = substitute(l:match, l:replacement[0], l:replacement[1], 'g')
		else
		    let l:match = substitute(l:match, (empty(a:pattern) ? @/ : a:pattern), l:replacement, '')
		endif
	    endif
	    if l:isUnique && index(l:matches, l:match) != -1
		continue
	    endif
	    if ! s:PredicateCheck(l:Predicate, l:context, l:originalMatch, l:match, l:startPos, l:endPos)
		continue
	    endif
	    call add(l:matches, l:match)
"****D echomsg '****' string(l:startPos) string(l:endPos) string(l:match)
	    if l:isOnlyFirstMatch
		normal! $
	    endif
	endwhile
    call winrestview(l:save_view)
    return l:matches
endfunction
function! s:PredicateCheck( Predicate, context, match, replacement, startPos, endPos ) abort
    if empty(a:Predicate) | return 1 | endif

    let a:context.match = a:match
    let a:context.matchStart = a:startPos
    let a:context.matchEnd = a:endPos
    let a:context.replacement = a:replacement
    let a:context.matchCount += 1

    let l:isAccepted = call(a:Predicate, [a:context])
    if l:isAccepted
	let a:context.acceptedCount += 1
    endif

    return l:isAccepted
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
