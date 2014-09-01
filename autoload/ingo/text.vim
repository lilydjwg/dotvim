" ingo/text.vim: Function for getting and setting text in the current buffer.
"
" DEPENDENCIES:
"   - ingo/pos.vim autoload script
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.006	30-Apr-2014	Use ingo/pos.vim.
"   1.018.005	06-Apr-2014	I18N: Correctly capture last multi-byte
"				character in ingo#text#Get(); don't just add one
"				to the end column, but instead match at the
"				column itself, too.
"				Add optional a:isExclusive flag to
"				ingo#text#Get(), as clients may end up with that
"				position, and doing a correct I18N-safe decrease
"				before getting the text is a hen-and-egg problem.
"   1.018.004	20-Mar-2014	FIX: Off-by-one: Allow column 1 in
"				ingo#text#Insert().
"				Add special cases for insertion at front and end
"				of line (in the hope that this is more
"				efficient).
"   1.016.003	16-Dec-2013	Add ingo#text#Insert() and ingo#text#Remove().
"   1.014.002	21-Oct-2013	Add ingo#text#GetChar().
"   1.011.001	23-Jul-2013	file creation from ingocommands.vim.

function! ingo#text#Get( startPos, endPos, ... )
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer.
"   Multiple lines will be delimited by a newline character.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startPos	    [line, col]
"   a:endPos	    [line, col]
"   a:isExclusive   Flag whether a:endPos is exclusive; by default, the
"		    character at that position is included; pass 1 to exclude
"		    it.
"* RETURN VALUES:
"   string text
"*******************************************************************************
    let [l:exclusiveOffset, l:exclusiveMatch] = (a:0 && a:1 ? [1, ''] : [0, '.'])
    let [l:line, l:column] = a:startPos
    let [l:endLine, l:endColumn] = a:endPos
    if ingo#pos#IsAfter([l:line, l:column], [l:endLine, l:endColumn + l:exclusiveOffset])
	return ''
    endif

    let l:text = ''
    while 1
	if l:line == l:endLine
	    let l:text .= matchstr(getline(l:line) . "\n", '\%' . l:column . 'c' . '.*\%' . l:endColumn . 'c' . l:exclusiveMatch)
	    break
	else
	    let l:text .= matchstr(getline(l:line) . "\n", '\%' . l:column . 'c' . '.*')
	    let l:line += 1
	    let l:column = 1
	endif
    endwhile
    return l:text
endfunction

function! ingo#text#GetChar( startPos, ... )
"*******************************************************************************
"* PURPOSE:
"   Extract one / a:count character(s) from a:startPos from the current buffer.
"   Only considers the current line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startPos	    [line, col]
"   a:count         Optional number of characters to extract; default 1.
"		    If this is a negative number, tries to extract as many as
"		    possible instead of not matching.
"* RETURN VALUES:
"   string text, or empty string if no(t enough) character(s).
"*******************************************************************************
    let [l:line, l:column] = a:startPos
    let [l:count, l:isUpTo] = (a:0 ? (a:1 > 0 ? [a:1, 0] : [-1 * a:1, 1]) : [0, 0])

    return matchstr(getline(l:line), '\%' . l:column . 'c' . '.' . (l:count ? '\{' . (l:isUpTo ? ',' : '') . l:count . '}' : ''))
endfunction

function! ingo#text#Insert( pos, text )
"******************************************************************************
"* PURPOSE:
"   Insert a:text at a:pos.
"* ASSUMPTIONS / PRECONDITIONS:
"   Buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the buffer.
"* INPUTS:
"   a:pos   [line, col]; col is the 1-based byte-index.
"   a:text  String to insert.
"* RETURN VALUES:
"   Flag whether the position existed and insertion was done.
"******************************************************************************
    let [l:lnum, l:col] = a:pos
    if l:lnum > line('$')
	return 0
    endif

    let l:line = getline(l:lnum)
    if l:col > len(l:line) + 1
	return 0
    elseif l:col < 1
	throw 'Insert: Column must be at least 1'
    elseif l:col == 1
	return (setline(l:lnum, a:text . l:line) == 0)
    elseif l:col == len(l:line) + 1
	return (setline(l:lnum, l:line . a:text) == 0)
    elseif l:col == len(l:line) + 1
	return (setline(l:lnum, l:line . a:text) == 0)
    endif
    return (setline(l:lnum, strpart(l:line, 0, l:col - 1) . a:text . strpart(l:line, l:col - 1)) == 0)
endfunction
function! ingo#text#Remove( pos, len )
"******************************************************************************
"* PURPOSE:
"   Remove a:len bytes of text at a:pos.
"* ASSUMPTIONS / PRECONDITIONS:
"   Buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the buffer.
"* INPUTS:
"   a:pos   [line, col]; col is the 1-based byte-index.
"   a:len   Number of bytes to remove.
"* RETURN VALUES:
"   Flag whether the position existed and removal was done.
"******************************************************************************
    let [l:lnum, l:col] = a:pos
    if l:lnum > line('$')
	return 0
    endif

    let l:line = getline(l:lnum)
    if l:col > len(l:line)
	return 0
    elseif l:col <= 1
	throw 'Remove(): Column must be at least 1'
    endif
    return (setline(l:lnum, strpart(l:line, 0, l:col - 1) . strpart(l:line, l:col - 1 + a:len)) == 0)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
