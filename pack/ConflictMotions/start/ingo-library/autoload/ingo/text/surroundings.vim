" ingo/text/surroundings.vim: Generic functions to surround text with something.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Helper: Make a:string a literal search expression.
function! s:Literal( string )
    return '\V' . escape(a:string, '\') . '\m'
endfunction

" Helper: Search for a:expr a:count times.
function! s:Search( expr, count, isBackward )
    for i in range(1, a:count)
	let l:lineNum = search( a:expr, (a:isBackward ? 'b' : '').'W' )
	if l:lineNum == 0
	    return 0
	endif
    endfor
    return l:lineNum
endfunction



" Based on the cursor position, visually selects the text delimited by the
" passed 'delimiterChar' to the left and right. Text between delimiters can
" be across multiple lines or empty. If the cursor rests already ON a
" delimiter, this one is taken as the first delimiter.
" The flag 'isInner' determines whether the selection includes the delimiters.
function! ingo#text#surroundings#ChangeEnclosedText( count, delimiterChar, isInner )
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " Special case: select nothing (by doing nothing :-) when inner change (with
    " count=1) and there are no or only newlines between the delimiters.
    " Once we're in Visual mode, at least the current char will be changed;
    " there is no 'null' selection possible.
    if ! ( (search( '\%#' . l:literalDelimiterExpr . '\n*' . l:literalDelimiterExpr ) > 0) && a:count == 1 && a:isInner )
	" Step right to consider the cursor position and search for leading
	" delimiter to the left.
	call ingo#cursor#move#Right()
	if s:Search(l:literalDelimiterExpr, 1, 1) > 0
	    if( a:isInner )
		call ingo#cursor#move#Right()
		normal! v
		call ingo#cursor#move#Left()
	    else
		normal! v
	    endif

	    " Now that we're in Visual mode, extend the selection until the
	    " trailing delimiter by searching to the right (from the original
	    " cursor position).
	    call setpos('.', l:save_cursor)
	    if s:Search(l:literalDelimiterExpr, a:count, 0) > 0
		if( ! a:isInner )
		    call ingo#cursor#move#Right()
		endif
	    else
		normal! v
		call setpos('.', l:save_cursor)
		call ingo#msg#WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	    endif
	else
	    call setpos('.', l:save_cursor)
	    call ingo#msg#WarningMsg('Leading ' . a:delimiterChar . ' not found')
	endif
    endif
endfunction

" Based on the cursor position, remove the passed 'delimiterChar' from the
" left and right. Text between delimiters can be across multiple lines or
" empty and will not be touched. If the cursor rests already ON a delimiter,
" this one is taken as the first delimiter.
function! ingo#text#surroundings#RemoveSingleCharDelimiters( count, delimiterChar )
    " This is the simplest algorithm; first search left for the leading delimiter,
    " then (from the original cursor position) in the other direction for the
    " trailing one. If both are found, remove the trailing and then the
    " (memorized) lead delimiter.
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " If the cursor rests already ON a delimiter, this one is taken as the first delimiter.
    call ingo#cursor#move#Right()
    if s:Search(l:literalDelimiterExpr, 1, 1) > 0
	let l:begin_cursor = getpos('.')
	call setpos('.', l:save_cursor)
	if s:Search(l:literalDelimiterExpr, a:count, 0) > 0
	    " Remove the trailing delimiter.
	    normal! "_x

	    " Determine the end position; when the leading delimiter is in the
	    " same line, this needs further adjustment.
	    call ingo#cursor#move#Left(l:begin_cursor[1] == line('.') ? 2 : 1)
	    let l:end_pos = getpos('.')

	    " Delete the leading delimiter.
	    call setpos('.', l:begin_cursor)
	    normal! "_x

	    " Mark the changed area.
	    call ingo#change#Set(getpos('.'), l:end_pos)
	else
	    call ingo#msg#WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	endif
    else
	call ingo#msg#WarningMsg('Leading ' . a:delimiterChar . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction

function! s:RemoveExprFromCursorPosition( expr )
    let l:save_col = col('.')
	let l:beforeLen = len(getline('.'))
	    execute 's/\%#' . a:expr . '//e'
	let l:afterLen = len(getline('.'))
    call cursor(0, l:save_col)

    return (l:beforeLen - l:afterLen)
endfunction
" Based on the cursor position, remove the passed delimiters from the
" left and right. Delimiters can be single chars or patterns. Text between
" delimiters can be across multiple lines or empty and will not be touched.
" The cursor must rest before the trailing delimiter.
function! ingo#text#surroundings#RemoveDelimiters( count, leadingDelimiterPattern, trailingDelimiterPattern, ... )
    " To cope with different delimiters, we first do a forward search for the
    " trailing delimiter, then go the other direction to the leading one.
    " Memorizing its position, it's back to the trailing one, which is
    " removed. Finally, the leading one is removed. This back-and-forth is
    " necessary because the replacement of delimiters changes the former
    " positions.
    let l:save_cursor = getpos('.')
    let l:literalLeadingDelimiterExpr  = '\V' . a:leadingDelimiterPattern
    let l:literalTrailingDelimiterExpr = '\V' . a:trailingDelimiterPattern

    if s:Search( l:literalTrailingDelimiterExpr, a:count, 0 ) > 0
	call setpos('.', l:save_cursor)
	if s:Search( l:literalLeadingDelimiterExpr, 1, 1 ) > 0
	    let l:begin_cursor = getpos('.')
	    call setpos('.', l:save_cursor)
	    if s:Search( l:literalTrailingDelimiterExpr, a:count, 0 ) > 0
		" Remove the trailing delimiter.
		call s:RemoveExprFromCursorPosition(l:literalTrailingDelimiterExpr)

		" Determine the end position.
		call ingo#cursor#move#Left()
		let l:end_pos = getpos('.')

		" Remove the leading delimiter.
		call setpos('.', l:begin_cursor)
		let l:beginByteDiff = s:RemoveExprFromCursorPosition(l:literalLeadingDelimiterExpr)

		" Adjust the end position when the leading delimiter is in the
		" same line.
		if l:begin_cursor[1] == l:end_pos[1]
		    let l:end_pos[2] -= l:beginByteDiff
		endif

		" Mark the changed area.
		call ingo#change#Set(getpos('.'), l:end_pos)
	    else
		throw "ASSERT: Trailing delimiter shouldn't vanish. "
	    endif
	else
	    call ingo#msg#WarningMsg('Leading ' . (a:0 ? a:1 : a:leadingDelimiterPattern) . ' not found')
	endif
    else
	call ingo#msg#WarningMsg('Trailing ' . (a:0 ? a:1 : a:trailingDelimiterPattern) . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction



function! ingo#text#surroundings#DoSurround( textBefore, textAfter )
    normal! gv""s$

    " Set paste type to characterwise; otherwise, linewise selections would be
    " pasted _below_ the surrounded characters.
    call setreg('"', '', 'av')
    execute 'normal! "_s' . a:textBefore . "\<C-R>\<C-O>\"" . a:textAfter . "\<Esc>"
endfunction
function! ingo#text#surroundings#SurroundWith( selectionType, textBefore, textAfter )
    if a:selectionType ==# 'z'
	" This special selection type assumes that the surrounded text has
	" already been captured in register z and replaced with a single
	" character. It is necessary for the "surround with one typed character"
	" mapping, so that the visual selection has already been captured and
	" the placeholder '$' is already shown to the user when the character is
	" queried.

	" Set paste type to characterwise; otherwise, linewise selections would
	" be pasted _below_ the surrounded characters.
	call setreg('z', '', 'av')
	execute 'normal! g`[' . visualmode() . 'g`]"_c' . a:textBefore . "\<C-R>\<C-O>z" . a:textAfter . "\<Esc>"

	" Mark the changed area.
	" The start of the change is already right, but the end is one after the
	" trailing delimiter. Use the cursor position instead, it is right.
	call setpos("']", getpos('.'))
    elseif index(['v', 'char', 'line', 'block'], a:selectionType) != -1
	if a:selectionType ==# 'char'
	    silent! execute 'normal! g`[vg`]'. (&selection ==# 'exclusive' ? 'l' : '') . "\<Esc>"
	elseif a:selectionType ==# 'line'
	    silent! execute "normal! g'[Vg']\<Esc>"
	elseif a:selectionType ==# 'block'
	    silent! execute "normal! g`[\<C-V>g`]". (&selection ==# 'exclusive' ? 'l' : '') . "\<Esc>"
	endif

	call ingo#register#KeepRegisterExecuteOrFunc(function('ingo#text#surroundings#DoSurround'), a:textBefore, a:textAfter)

	" Mark the changed area.
	" The start of the change is already right, but the end is one after the
	" trailing delimiter. Use the cursor position instead, it is right.
	call setpos("']", getpos('.'))
    else
	if a:selectionType ==# 'w'
	    let l:backmotion = 'b'
	    let l:backendmotion = 'e'
	elseif a:selectionType ==# 'W'
	    let l:backmotion = 'B'
	    let l:backendmotion = 'E'
	else
	    throw "This selection type has not been implemented."
	endif

	let l:count = (v:count ? v:count : '')
	let l:save_cursor = getpos('.')
	execute 'normal! w' . l:backmotion . "i". a:textBefore . "\<Esc>"
	let l:begin_pos = getpos("'[")

	execute 'normal!' l:count . l:backendmotion . "a" . a:textAfter . "\<Esc>"
	let l:end_pos = getpos(".") " Use the cursor position; '] is one after the change.

	" Adapt saved cursor position to consider inserted text.
	let l:save_cursor[2] += strlen(a:textBefore)
	call cursor(l:save_cursor[1:2]) " Use cursor() instead of setpos('.') to set the curswant column for subsequent vertical movement.

	" Mark the changed area.
	call ingo#change#Set(l:begin_pos, l:end_pos)
    endif
endfunction

function! ingo#text#surroundings#SurroundWithSingleChar( selectionType, char )
    call ingo#text#surroundings#SurroundWith( a:selectionType, a:char, a:char )
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
