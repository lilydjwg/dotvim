" mark/cascade.vim: Cascading search through all used mark groups.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2015-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" Version:     3.0.0

let [s:cascadingLocation, s:cascadingPosition, s:cascadingGroupIndex, s:cascadingIsBackward, s:cascadingStop] = [[], [], -1, -1, -1]
function! s:GetLocation()
	return [tabpagenr(), winnr(), bufnr('')]
endfunction
function! s:SetCascade()
	let s:cascadingLocation = s:GetLocation()
	let [l:markText, s:cascadingPosition, s:cascadingGroupIndex] = mark#CurrentMark()
endfunction
function! mark#cascade#Start( count, isStopBeforeCascade )
	" Try passed mark group, current mark, last search, first used mark group, in that order.

	let s:cascadingIsBackward = -1
	let s:cascadingVisitedBuffers = {}
	call s:SetCascade()
	if (! a:count && s:cascadingGroupIndex != -1) || (a:count && s:cascadingGroupIndex + 1 == a:count)
		" We're already on a mark [with its group corresponding to count]. Take
		" that as the start and stay there (as we don't know which direction
		" (forward / backward) to take).
		return 1
	endif

	" Search for next mark and start cascaded search there.
	if ! mark#SearchGroupMark(a:count, 1, 0, 1)
		if a:count
			return 0
		elseif ! mark#SearchGroupMark(mark#NextUsedGroupIndex(0, 0, -1, 1) + 1, 1, 0, 1)
			call mark#NoMarkErrorMessage()
			return 0
		endif
	endif
	call s:SetCascade()
	return 1
endfunction
function! mark#cascade#Next( count, isStopBeforeCascade, isBackward )
	if s:cascadingIsBackward == -1
		let s:cascadingIsBackward = a:isBackward
	endif

	if s:cascadingGroupIndex == -1
		call ingo#err#Set('No cascaded search defined')
		return 0
	elseif get(s:cascadingVisitedBuffers, bufnr(''), -1) == s:cascadingGroupIndex && s:cascadingLocation != s:GetLocation()
		" We've returned to a buffer that had previously already been searched
		" for the current mark. Instead of searching again, cascade to the next
		" group.
		let s:cascadingLocation = s:GetLocation()
		return s:Cascade(a:count, 0, a:isBackward)
	elseif s:cascadingStop != -1
		if s:cascadingLocation == s:GetLocation()
			" Within the same location: Switch to the next mark group.
			call s:SwitchToNextGroup(s:cascadingStop, a:isBackward)
		else
			" Allow to continue searching for the current mark group in other
			" locations.
			call s:ClearLocationAndPosition()
		endif
		let s:cascadingStop = -1
	elseif s:cascadingIsBackward != a:isBackward && s:cascadingLocation == s:GetLocation() && s:cascadingPosition == getpos('.')[1:2]
		" We've just cascaded to the next mark group, and now want back to the
		" previous one (by reversing search direction).
		return s:Cascade(a:count, a:isStopBeforeCascade, a:isBackward)
	endif

	let l:save_wrapscan = &wrapscan
	set wrapscan
	let l:save_view = winsaveview()
	try
		if ! mark#SearchGroupMark(s:cascadingGroupIndex + 1, a:count, a:isBackward, 1)
			return s:Cascade(a:count, a:isStopBeforeCascade, a:isBackward)
		endif
		if s:cascadingLocation == s:GetLocation()
			if s:cascadingPosition == getpos('.')[1:2]
				if s:cascadingIsBackward == a:isBackward
					" We're returned to the first match from that group. Undo
					" that last jump, and then cascade to the next one.
					call winrestview(l:save_view)
					return s:Cascade(a:count, a:isStopBeforeCascade, a:isBackward)
				else
					" Search direction has been reversed (from what it was when
					" the cascading position has been established). The current
					" match is now the last valid mark before cascading (in the
					" other direction). To recognize that, search for the next
					" match in the reversed direction, and set its position and
					" direction, then stay put here.
					let l:save_view = winsaveview()
						silent call mark#SearchGroupMark(s:cascadingGroupIndex + 1, 1, a:isBackward, 1)
						let s:cascadingPosition = getpos('.')[1:2]
						let s:cascadingIsBackward = a:isBackward
					call winrestview(l:save_view)
					return 1
				endif
			endif
		endif

		if empty(s:cascadingLocation) && empty(s:cascadingPosition)
			call s:SetCascade()
		endif

		return 1
	finally
		let &wrapscan = l:save_wrapscan
	endtry
endfunction
function! s:Cascade( count, isStopBeforeCascade, isBackward )
	let l:nextGroupIndex = mark#NextUsedGroupIndex(a:isBackward, 0, s:cascadingGroupIndex, 1)
	if l:nextGroupIndex == -1
		redraw  " Get rid of the previous mark search message.
		call ingo#err#Set(printf('Cascaded search ended with %s used group', (a:isBackward ? 'first' : 'last')))
		return 0
	endif

	let s:cascadingVisitedBuffers[bufnr('')] = s:cascadingGroupIndex
	if a:isStopBeforeCascade
		let s:cascadingStop = l:nextGroupIndex
		redraw  " Get rid of the previous mark search message.
		call ingo#msg#WarningMsg('Cascaded search reached last match of current group')
		return 1
	else
		call s:SwitchToNextGroup(l:nextGroupIndex, a:isBackward)
		return mark#cascade#Next(a:count, a:isStopBeforeCascade, a:isBackward)
	endif
endfunction
function! s:SwitchToNextGroup( nextGroupIndex, isBackward )
	let s:cascadingGroupIndex = a:nextGroupIndex
	let s:cascadingIsBackward = a:isBackward
	call s:ClearLocationAndPosition()
endfunction
function! s:ClearLocationAndPosition()
	let [s:cascadingLocation, s:cascadingPosition] = [[], []]   " Clear so that the next mark match will re-initialize them with the base match for the new mark group.
endfunction

" vim: ts=4 sts=0 sw=4 noet
