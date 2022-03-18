" ingo/selection/area.vim: Functions for getting the area of the selection.
"
" DEPENDENCIES:
"   - ingo/pos.vim autoload script
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#selection#area#Get( ... )
"******************************************************************************
"* PURPOSE:
"   Get the start and end position of the current selection. The end position is
"   always _on_ the last selected character, even when 'selection' is
"   "exclusive'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isClipLinewise	        Optional flag whether the end column of
"					linewise selections should be clipped to
"					the last character before the newline.
"					Else, the end column will be 0x7FFFFFFF
"					for linewise selections. Default on.
"   a:options.returnValueOnNoSelection  Optional return value if no selection
"					has yet been made. If omitted, [[0, 0],
"					[0, 0]] will be returned.
"* RETURN VALUES:
"   [[startLnum, startCol], [endLnum, endCol]], or a:returnValueOnNoSelection
"   endCol points to the last character, not beyond it!
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isClipLinewise = get(l:options, 'isClipLinewise', 1)

    let l:startPos = getpos("'<")[1:2]
    let l:endPos = getpos("'>")[1:2]
    if l:startPos == [0, 0] && l:endPos == [0, 0]
	return get(l:options, 'returnValueOnNoSelection', [l:startPos, l:endPos])
    endif

    if &selection ==# 'exclusive'
	let l:isCursorAfterSelection = ingo#pos#IsOnOrAfter(getpos('.')[1:2], l:endPos)
	let l:searchPos = searchpos('\_.\%''>', (l:isCursorAfterSelection ? 'b' : '') . 'cnW', line("'>") + (l:isCursorAfterSelection ? -1 : 0))
	if l:searchPos != [0, 0] " This happens with a linewise selection, where col = 0x7FFFFFFF. No need to adapt that.
	    let l:endPos = l:searchPos
	endif
    endif

    if l:isClipLinewise
	let l:endPos[1] = min([len(getline(l:endPos[0])), l:endPos[1]])
    endif

    return [l:startPos, l:endPos]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
