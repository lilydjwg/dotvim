" ingo/print/highlighted.vim: :echo a line from the buffer with the original syntax highlighting.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" Source: Based on ShowLine.vim (vimscript #381) by Gary Holloway
let s:save_cpo = &cpo
set cpo&vim

function! s:GetCharacter( line, column )
"*******************************************************************************
"* PURPOSE:
"   Retrieve a (full, in case of multi-byte) character from a:line, a:column.
"   strpart(getline(a:line), a:column, 1) can only deal with single-byte chars.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"
"* RETURN VALUES:
"   Character, or empty string if the position is invalid.
"*******************************************************************************
    return matchstr(a:line, '\%' . a:column . 'c.')
endfunction

function! s:GetTabReplacement( column, tabstop )
    return a:tabstop - (a:column - 1) % a:tabstop
endfunction

function! s:IsMoreToRead( column )
    if a:column > s:endCol
	return 0
    endif
    if s:maxLength <= 0
	return 1
    endif

    " The end column has not been reached yet, but a maximum length has been
    " set. We need to determine whether the next character would still fit.
    let l:isMore =  (ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1 <= s:maxLength)
"****D echomsg 'at column' a:column strpart(getline(s:lineNum), a:column - 1, 1) 'will have length' (ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1) (l:isMore ? 'do it' : 'stop')
    return l:isMore
endfunction
function! s:IsInside( startCol, endCol, column )
    return (a:column >= a:startCol && a:column <= a:endCol)
endfunction
function! s:GetAdditionalHighlightGroup( column )
    for l:h in s:additionalHighlighting
	if s:IsInside(l:h[0], l:h[1], a:column)
	    return l:h[2]
	endif
    endfor
    return ''
endfunction
function! s:GetHighlighting( line, column )
    let l:group = s:GetAdditionalHighlightGroup(a:column)
    return (empty(l:group) ?
    \	synIDattr(synID(a:line, a:column, 1), 'name') :
    \	l:group
    \)
endfunction

function! ingo#print#highlighted#LinePart( lineNum, startCol, endCol, maxLength, additionalHighlighting )
"*******************************************************************************
"* PURPOSE:
"   Display the current buffer's a:lineNum in the command line, using that
"   line's syntax highlighting. Additional highlight groups can be applied on
"   top.
"* ASSUMPTIONS / PRECONDITIONS:
"   l:lineNum refers to existing line in current buffer.
"* EFFECTS / POSTCONDITIONS:
"   :echo's to the command line.
"* INPUTS:
"   a:lineNum	Line number in current buffer to be displayed.
"   a:startCol	Column number from where to start displaying (0: column 1).
"   a:endCol	Last column number to be displayed (0: line's last column).
"   a:maxLength	Maximum number of characters to be displayed; this can be
"		different from (a:endCol - a:startCol) if the line contains
"		<Tab> characters, and is useful to avoid the "Hit ENTER" prompt.
"		(0: unlimited length)
"   a:additionalHighlighting
"		List of additional highlightings that should be layered on top
"		of the line's highlighting. Each list element consists of
"		[ startCol, endCol, highlightGroup ]. In case there is overlap
"		in the ranges, the first element that specifies a highlight
"		group for a column wins.
"* RETURN VALUES:
"   none
"*******************************************************************************
    let l:cmd = ''
    let l:prev_group = ' '    " Something that won't match any syntax group name.
    let l:line = getline(a:lineNum)

    let l:column = (a:startCol == 0 ? 1 : a:startCol)
    let l:additionalSpecialCharacterExpr = (&list ? '^\%( \|\%xa0\|\%u202f\)' : '')
    let l:isLeadingSpace = (l:column == 1)

    let s:virtStartCol = ingo#mbyte#virtcol#GetVirtStartColOfCurrentCharacter(a:lineNum, l:column)
    let s:endCol = (a:endCol == 0 ? strlen(l:line) : a:endCol)
    let s:lineNum = a:lineNum
    let s:maxLength = a:maxLength
    let s:additionalHighlighting = a:additionalHighlighting

    if l:column == s:endCol
	let l:cmd .= 'echon "'
    endif

"****D echomsg 'start at virtstartcol' s:virtStartCol
    while s:IsMoreToRead( l:column )
	let l:char = s:GetCharacter(l:line, l:column)
	if l:char !=# ' '
	    let l:isLeadingSpace = 0
	endif
	let l:group = s:GetHighlighting(a:lineNum, l:column)

	if l:char =~# '\%(\p\@![\x00-\xFF]\)' || (! empty(l:additionalSpecialCharacterExpr) && l:char =~# l:additionalSpecialCharacterExpr)
	    " Emulate the built-in highlighting of translated unprintable
	    " characters here. The regexp also matches <CR> and <LF>, but no
	    " non-ASCII multi-byte characters; the 'isprint' option is not
	    " applicable to them.
	    let l:group = 'SpecialKey'
	endif

	if l:group != l:prev_group
	    let l:cmd .= (empty(l:cmd) ? '' : '"|')
	    let l:cmd .= 'echohl ' . (empty(l:group) ? 'None' : l:group) . '|echon "'
"****D echomsg '****' printf('%4s', '"'. strtrans(l:char) . '"') l:group
	    let l:prev_group = l:group
	endif

	" <Tab> characters are rendered so that the tab width is the same as in
	" the buffer (even when the echoed position is shifted due to scrolling
	" or a echo prefix).
	"
	" The :echo command observes embedded line breaks (in contrast to
	" :echomsg), which would mess up a single-line message that contains
	" embedded \n = <CR> = ^M or <LF> = ^@.
	if l:char ==# "\t" || (! empty(l:additionalSpecialCharacterExpr) && l:char =~# l:additionalSpecialCharacterExpr)
	    let l:width = s:GetTabReplacement(ingo#mbyte#virtcol#GetVirtStartColOfCurrentCharacter(a:lineNum, l:column), &l:tabstop)
	    let l:cmd .= (&list ?
	    \   escape(ingo#option#listchars#Render(l:char, {'tabWidth': l:width, 'fallback': {'tab': '^I'}, 'isTextAtStart': l:isLeadingSpace}), '"\') :
	    \   repeat(' ', l:width)
	    \)
	elseif l:char ==# "\<CR>"
	    let l:cmd .= '^M'
	elseif l:char ==# "\<LF>"
	    let l:cmd .= '^@'
	else
	    let l:cmd .= escape(l:char, '"\')
	endif
	let l:column += strlen(l:char)
    endwhile
"****D echomsg '**** from' s:virtStartCol 'last col added' l:column - 1 | echomsg ''

    if a:maxLength > 0 && s:GetCharacter(l:line, l:column) ==# "\t"
	" The line has been truncated before a <Tab> character, so the maximum
	" length has not been used up. As there may be a highlighting prolonged
	" by the <Tab>, we still want to fill up the maximum length.
	let l:width = s:virtStartCol + a:maxLength - ingo#mbyte#virtcol#GetVirtStartColOfCurrentCharacter(a:lineNum, l:column)
	if empty(l:cmd)
	    let l:cmd .= 'echon "'
	endif
	let l:cmd .= (&list ?
	\   escape(ingo#option#listchars#Render(l:char, {'tabWidth': l:width, 'fallback': {'tab': '^I'}}), '"\') :
	\   repeat(' ', l:width)
	\)
    endif

    if a:maxLength != 1 && l:column > s:endCol && &list
	let l:char = ingo#option#listchars#Render('', {'isTextAtEnd': 1})
	if ! empty(l:char)
	    let l:cmd .= '"|echohl SpecialKey|echon "' . escape(l:char, '"\')
	endif
    endif

    let l:cmd .= '"|echohl None'
"****D call input('CMD='.l:cmd)
    execute l:cmd
endfunction

function! ingo#print#highlighted#Line( lineNum, centerCol, prefix, additionalHighlighting )
"*******************************************************************************
"* PURPOSE:
"   Display (part of) the current buffer's a:lineNum in the command line without
"   causing the "Hit ENTER" prompt, using that line's syntax highlighting.
"   Additional highlight groups can be applied on top. The a:prefix text is
"   displayed before the line. When the line is too long to be displayed
"   completely, the a:centerCol column is centered, and parts of the line before
"   and after that are truncated.
"* ASSUMPTIONS / PRECONDITIONS:
"   l:lineNum refers to existing line in current buffer.
"* EFFECTS / POSTCONDITIONS:
"   :echo's to the command line, avoiding the "Hit ENTER" prompt.
"* INPUTS:
"   a:lineNum	Line number in current buffer to be displayed.
"   a:centerCol	Column number of the line that will be centered if the line is
"		too long to be displayed completely. Use 0 for truncation only
"		at the right side.
"   a:prefix	String that will be echoed before the line.
"   a:additionalHighlighting
"		List of additional highlightings that should be layered on top
"		of the line's highlighting. Each list element consists of
"		[ startCol, endCol, highlightGroup ]. In case there is overlap
"		in the ranges, the first element that specifies a highlight
"		group for a column wins.
"* RETURN VALUES:
"   none
"*******************************************************************************
    let l:maxLength = ingo#avoidprompt#MaxLength() - ingo#compat#strdisplaywidth(a:prefix)
    let l:line = getline(line('.'))

    " The a:centerCol is specified in buffer columns, but the l:maxLength is in
    " screen space. To (more or less) bridge this mismatch, a constant factor of
    " 0 < (# of chars / bytes) <= 100 is assumed.
    let l:numOfChars = strlen(substitute(ingo#tabstops#Render(l:line), '.', 'x', 'g'))
    let l:lengthToColFactor = 100 * l:numOfChars / strlen(l:line)
"****D echomsg '****' l:lengthToColFactor
    " Attention: columns start with 1, byteidx() starts with 0!
    let l:startCol = byteidx( l:line, max([1, (a:centerCol * l:lengthToColFactor / 100) - (l:maxLength / 2)]) - 1 ) + 1

    echon a:prefix
    call ingo#print#highlighted#LinePart(a:lineNum, l:startCol, 0, l:maxLength, a:additionalHighlighting)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
