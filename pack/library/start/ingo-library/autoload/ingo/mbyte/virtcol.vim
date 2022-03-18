" ingo/mbyte/virtcol.vim: Multibyte-aware translation functions between byte index and virtcol.
"
" DEPENDENCIES:

" Copyright: (C) 2009-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#mbyte#virtcol#GetVirtStartColOfCurrentCharacter( lineNum, column )
    let l:currentVirtCol = ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column - l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset]) + 1
endfunction
function! ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter( lineNum, column )
    " virtcol() only returns the (end) virtual column of the current character
    " if the column points to the first byte of a multi-byte character. If we're
    " pointing to the middle or end of a multi-byte character, the end virtual
    " column of the _next_ character is returned.
    let l:offset = 1
    while a:column - l:offset > 0 && virtcol([a:lineNum, a:column - l:offset]) == virtcol([a:lineNum, a:column + 1])
	" If the next column's virtual column is the same, we're in the middle
	" of a multi-byte character, and must backtrack to get this character's
	" virtual column.
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset + 1])
endfunction
function! ingo#mbyte#virtcol#GetVirtColOfNextCharacter( lineNum, column )
    let l:currentVirtCol = ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column + l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column + l:offset])
endfunction

function! ingo#mbyte#virtcol#GetColOfVirtCol( lineNum, virtCol )
    let l:col = searchpos(printf('\%%%dl.\%%>%dv', a:lineNum, a:virtCol), 'cnw')[1]
    return (l:col > 0 ? l:col : len(getline(a:lineNum)) + 1)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
