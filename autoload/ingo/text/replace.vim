" ingo/text/replace.vim: Functions to replace a pattern with text.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.007	31-May-2014	Also set the change marks to the replaced area.
"				Make col argument 1-based for consistency.
"   1.020.006	30-May-2014	Factor out and expose ingo#text#Replace#Area().
"				Allow a:Text Funcref in
"				ingo#text#replace#PatternWithText().
"				CHG: When replacing at the cursor position, also
"				jump to the beginning of the replacement. This
"				is more consistent with Vim's default behavior.
"   1.011.005	23-Jul-2013	Move into ingo-library.
"	004	11-Apr-2013	ENH: ingoreplacer#ReplaceText() returns
"				structure with the original and replaced text.
"				Use ingo#msg#WarningMsg() from ingo-library.
"				Extract user output into separate
"				ingoreplacer#ReplaceTextWithMessage() function.
"	003	07-May-2012	As an optimization, use l:maxCount for "last"
"				location when already determined by "current" location.
"	002	06-May-2012	ENH: Change default strategy to current match,
"				then next match (instead of last match), and
"				allow passing of different strategy of choosing
"				the match locations.
"	001	06-May-2012	file creation from plugin/InsertDate.vim

function! s:ReplaceRange( source, startIdx, endIdx, string )
    return strpart(a:source, 0, a:startIdx) . a:string . strpart(a:source, a:endIdx + 1)
endfunction

function! ingo#text#replace#Area( startPos, endPos, Text )
"******************************************************************************
"* PURPOSE:
"   Replace the text between a:startPos and a:endPos from the current buffer
"   with a:Text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Modifies current buffer.
"   Sets the change marks '[,'] to the modified area.
"* INPUTS:
"   a:startPos  [line, col]
"   a:endPos    [line, col]
"   a:Text      Replacement text, or Funcref that gets passed the text to
"		replace, and returns the replacement text.
"* RETURN VALUES:
"   List of [originalText, replacementText, didReplacement].
"******************************************************************************
    if a:startPos[0] != a:endPos[0]
	throw 'Multi-line replacement not implemented yet'
    endif

    let l:line = getline(a:startPos[0])
    let l:currentText = strpart(l:line, a:startPos[1] - 1, (a:endPos[1] - a:startPos[1] + 1))
    if type(a:Text) == type(function('tr'))
	let l:text = call(a:Text, [l:currentText])
    else
	let l:text = a:Text
    endif

    " Because of setline(), we can only (easily) handle text replacement in a
    " single line, so replace with the first (non-empty) line only should the
    " replacement text consist of multiple lines.
    let l:text = split(l:text, "\n")[0]

    if l:currentText !=# l:text
	call setline('.', s:ReplaceRange(l:line, a:startPos[1] - 1, a:endPos[1] - 1, l:text))
	call setpos("'[", [0, a:startPos[0], a:startPos[1], 0])
	call setpos("']", [0, a:startPos[0], a:startPos[1] + len(l:text) - len(matchstr(l:text, '.$')), 0])
	return [l:currentText, l:text, 1]
    else
	" The range already contains the new text in the correct format, no
	" replacement was done.
	return [l:currentText, l:text, 0]
    endif
endfunction
function! s:ReplaceTextInRange( startIdx, endIdx, Text, where )
    let [l:originalText, l:replacementText, l:didReplacement] = ingo#text#replace#Area([line('.'), a:startIdx + 1], [line('.'), a:endIdx + 1], a:Text)
    if l:didReplacement
	call cursor(line('.'), a:startIdx + 1)
	return {'startIdx': a:startIdx, 'endIdx': a:endIdx, 'original': l:originalText, 'replacement': l:replacementText, 'where': a:where}
    else
	return []
    endif
endfunction

function! ingo#text#replace#PatternWithText( pattern, Text, ... )
"******************************************************************************
"* PURPOSE:
"   Replace occurrences of a:pattern in the current line with a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current line.
"* INPUTS:
"   a:pattern   Regular expression that defines the text to replace.
"   a:Text      Replacement text, or Funcref that gets passed the text to
"		replace, and returns the replacement text.
"   a:strategy  Array of locations where in the current line a:pattern will
"		match. Possible values: 'current', 'next', 'last'. The default
"		is ['current', 'next'], to have the same behavior as the
"		built-in "*" command.
"* RETURN VALUES:
"   Object with replacement information: {'startIdx', 'endIdx', 'original',
"   'replacement', 'where'}, or empty Dictionary if no replacement was done.
"******************************************************************************
    let l:strategy = (a:0 ? copy(a:1) : ['current', 'next'])

    " Substitute any of the text patterns with the current text in the current
    " text format.
    let l:line = getline('.')

    while ! empty(l:strategy)
	let l:location = remove(l:strategy, 0)
	if l:location ==# 'current'
	    " If the cursor is positioned on a text, update that one.
	    let l:cursorIdx = col('.') - 1
	    let l:startIdx = 0
	    let l:count = 0
	    while l:startIdx != -1
		let l:count += 1
		let l:startIdx = match(l:line, a:pattern, 0, l:count)
		let l:endIdx = matchend(l:line, a:pattern, 0, l:count) - 1
		if l:startIdx <= l:cursorIdx && l:cursorIdx <= l:endIdx
"****D echomsg '**** cursor match from ' . l:startIdx . ' to ' . l:endIdx
		    let l:result = s:ReplaceTextInRange(l:startIdx, l:endIdx, a:Text, '%s at cursor position')
		    if ! empty(l:result) | return l:result | endif
		endif
	    endwhile
	    let l:maxCount = l:count
	elseif l:location ==# 'next'
	    " Update the next text (that is not already the current text and
	    " format) found in the line.
	    let l:cursorIdx = col('.') - 1
	    let l:startIdx = 0
	    let l:count = 0
	    while l:startIdx != -1
		let l:count += 1
		let l:startIdx = match(l:line, a:pattern, l:cursorIdx, l:count)
		let l:endIdx = matchend(l:line, a:pattern, l:cursorIdx, l:count) - 1
"****D echomsg '**** next match from ' . l:startIdx . ' to ' . l:endIdx
		if l:startIdx != -1
		    let l:result = s:ReplaceTextInRange(l:startIdx, l:endIdx, a:Text, 'next %s in line')
		    if ! empty(l:result) | return l:result | endif
		endif
	    endwhile
	elseif l:location ==# 'last'
	    " Update the last text (that is not already the current text and
	    " format) found in the line. This will update non-current texts from last to
	    " first on subsequent invocations until all occurrences are current.
	    let l:count = (exists('l:maxCount') ? l:maxCount - 1 : len(l:line))   " XXX: This is ineffective but easier than first counting the matches.
	    while l:count > 0
		let l:startIdx = match(l:line, a:pattern, 0, l:count)
		let l:endIdx = matchend(l:line, a:pattern, 0, l:count) - 1
"****D echomsg '**** last match from ' . l:startIdx . ' to ' . l:endIdx . ' at count ' . l:count
		if l:startIdx != -1
		    let l:result = s:ReplaceTextInRange(l:startIdx, l:endIdx, a:Text, 'last %s in line')
		    if ! empty(l:result) | return l:result | endif
		endif
		let l:count -= 1
	    endwhile
	else
	    throw 'ASSERT: Unknown strategy location: ' . l:location
	endif
    endwhile

    return {}
endfunction
function! ingo#text#replace#PatternWithTextAndMessage( what, pattern, text, ... )
    let l:replacement = call('ingo#text#replace#PatternWithText', [a:pattern, a:text] + a:000)
    if empty(l:replacement)
	call ingo#msg#WarningMsg(printf('No %s was found in this line', a:what))
    else
	echo 'Updated' printf(l:replacement.where, a:what)
    endif
    return l:replacement
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
