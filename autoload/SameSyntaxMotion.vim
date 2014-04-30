" SameSyntaxMotion.vim: Motions to the borders of the same syntax highlighting.
"
" DEPENDENCIES:
"   - CountJump.vim autoload script, version 1.80 or higher
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.008	18-Sep-2012	Handle same syntax areas at the beginning and
"				end of the buffer; in those cases, the
"				wrap-around ends the syntax area, and we must
"				only search for the last of the syntax area
"				without wrapping.
"	007	18-Sep-2012	Support wrapped search for motions through
"				HlgroupMotion#JumpWithWrapMessage() overload.
"				FIX: When checking whether the original synID is
"				in the syntax stack, only elements on top of it
"				are relevant. Need to compare the found indices
"				instead of simply checking for containment.
"				Rename s:IsSynIDHere() to
"				s:IsSynIDContainedHere() to better reflect this.
"	006	17-Sep-2012	Implement inner jump that stays in the current
"				line, does not cross unhighlighted
"				whitespace, and does not include whitespace
"				around the syntax area.
"				Use that to define an inner text object, too.
"				Shuffle a:flags argument to the back for better
"				grouping.
"	005	16-Sep-2012	Optimization: Speed up iteration by performing
"				the synID()-lookup only once on each position
"				and by caching the result of the
"				synstack()-search for each current synID. Even
"				though this contributed only 40% to the runtime
"				(the other 40% is for synID(), 10% for the
"				searchpos()), it somehow also reduces the time
"				for synID() lookups dramatically.
"	004	15-Sep-2012	Replace s:Jump() with generic implementation by
"				CountJump, CountJump#CountJumpFunc().
"	003	14-Sep-2012	Implement text object. Factor out s:Jump() to
"				allow passing in the original syntaxId and
"				hlgroupId; it may be different at the text
"				object begin and therefore may adulterate the
"				end match.
"	002	13-Sep-2012	Implement the full set of the four begin/end
"				forward/backward mappings.
"				Implement skipping over unhighlighted
"				whitespace when its surrounded by the same
"				syntax area on both sides.
"				Handle situations where due to :syntax hs=s+1 or
"				contained groups (like vimCommentTitle contained
"				in vimLineComment) the same highlighting may
"				start only later in the syntax area, while still
"				skipping over contained "subsyntaxes" (like that
"				quote here) inside the syntax area.
"	001	12-Sep-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:GetHlgroupId( synID )
    return synIDtrans(a:synID)
endfunction
function! s:GetCurrentSyntaxAndHlgroupIds()
    let l:currentSyntaxId = synID(line('.'), col('.'), 1)
    return [l:currentSyntaxId, s:GetHlgroupId(l:currentSyntaxId)]
endfunction
function! s:IsSynIDContainedHere( line, col, synID, currentSyntaxId, synstackCache )
    if ! has_key(a:synstackCache, a:currentSyntaxId)
	let l:synstack = synstack(a:line, a:col)
	let l:synIdIndex = index(l:synstack, a:synID)
	" To be contained in the original syntax (represented by a:synID), that
	" syntax must still be part of the syntax stack and the current syntax
	" must be on top of it.
	" Note: a:currentSyntaxId is guaranteed to be in the syntax stack, no
	" need to check for containment.
	let a:synstackCache[a:currentSyntaxId] = (l:synIdIndex != -1 && index(l:synstack, a:currentSyntaxId) >= l:synIdIndex)
    endif
    return a:synstackCache[a:currentSyntaxId]
endfunction
function! s:IsWithoutHighlighting( synID )
    return empty(
    \   filter(
    \       map(['fg', 'bg', 'sp'], 'synIDattr(a:synID, "v:val")'),
    \       '! empty(v:val)'
    \   )
    \)
endfunction
function! s:IsWhitespaceHere( line )
    return search('\%#\s', 'cnW', a:line) != 0
endfunction
function! s:IsUnhighlightedWhitespaceHere( line, currentSyntaxId )
    if ! s:IsWhitespaceHere(a:line)
	return 0
    endif

    if synIDtrans(a:currentSyntaxId) == 0
	" No effective syntax group here.
	return 1
    endif

    if s:IsWithoutHighlighting(a:currentSyntaxId)
	" The syntax group has no highlighting defined.
	return 1
    endif

    return 0
endfunction
function! SameSyntaxMotion#SearchFirstOfSynID( synID, hlgroupId, flags, isInner )
    let l:isBackward = (a:flags =~# 'b')
    let l:originalPosition = getpos('.')[1:2]
    let l:matchPosition = []
    let l:hasLeft = 0
    let l:synstackCache = {}

    while l:matchPosition != l:originalPosition
	let l:matchPosition = searchpos('.', a:flags, (a:isInner ? line('.') : 0))
	if l:matchPosition == [0, 0]
	    " We've arrived at the buffer's border.
	    call setpos('.', [0] + l:originalPosition + [0])
	    return l:matchPosition
	endif

	let [l:currentSyntaxId, l:currentHlgroupId] = s:GetCurrentSyntaxAndHlgroupIds()
	if l:currentHlgroupId == a:hlgroupId
	    if ! l:isBackward && l:matchPosition == [1, 1] && l:matchPosition != l:originalPosition
		" This is no circular buffer; text at the buffer start is
		" separate from the end. Break up the syntax area to correctly
		" handle matches at both beginning and end of the buffer.
		let l:hasLeft = 1
	    endif

	    " We're still / again inside the same-colored syntax area.
	    if l:hasLeft
		" We've found a place in the next syntax area with the same
		" color.
		return l:matchPosition
	    endif

	    if l:isBackward && l:matchPosition == [1, 1]
		" This is no circular buffer; text at the buffer start is
		" separate from the end. Break up the syntax area to correctly
		" handle matches at both beginning and end of the buffer.
		let l:hasLeft = 1
	    endif
	elseif s:IsSynIDContainedHere(l:matchPosition[0], l:matchPosition[1], a:synID, l:currentSyntaxId, l:synstackCache)
	    " We're still / again inside the syntax area.
	    " Progress until we also find the desired color in this syntax area.
	elseif ! a:isInner && s:IsUnhighlightedWhitespaceHere(l:matchPosition[0], l:currentSyntaxId)
	    " Tentatively progress; the same syntax area may continue after the
	    " plain whitespace. But if it doesn't, we do not include the
	    " whitespace.
	else
	    " We've just left the syntax area.
	    let l:hasLeft = 1
	    " Keep on searching for the next syntax area.
	endif
    endwhile

    " We've wrapped around and arrived at the original position without a match.
    return [0, 0]
endfunction
function! SameSyntaxMotion#SearchLastOfSynID( synID, hlgroupId, flags, isInner )
    let l:flags = a:flags
    let l:originalPosition = getpos('.')[1:2]
    let l:goodPosition = [0, 0]
    let l:matchPosition = []
    let l:synstackCache = {}

    while l:matchPosition != l:originalPosition
	let l:matchPosition = searchpos('.', l:flags, (a:isInner ? line('.') : 0))
	if l:matchPosition == [0, 0]
	    " We've arrived at the buffer's border.
	    break
	endif

	let [l:currentSyntaxId, l:currentHlgroupId] = s:GetCurrentSyntaxAndHlgroupIds()
	if l:currentHlgroupId == a:hlgroupId
	    if a:isInner && s:IsWhitespaceHere(l:matchPosition[0])
		" We don't include whitespace around the syntax area in the
		" inner jump.
		continue
	    endif

	    " We're still / again inside the same-colored syntax area.
	    let l:goodPosition = l:matchPosition
	    " Go on (without wrapping now!) until we've reached the start of the
	    " syntax area.
	    let l:flags = substitute(l:flags, '[wW]', '', 'g') . 'W'
	elseif s:IsSynIDContainedHere(l:matchPosition[0], l:matchPosition[1], a:synID, l:currentSyntaxId, l:synstackCache)
	    " We're still inside the syntax area.
	    " Tentatively progress; we may again find the desired color in this
	    " syntax area.
	elseif ! a:isInner && s:IsUnhighlightedWhitespaceHere(l:matchPosition[0], l:currentSyntaxId)
	    " Tentatively progress; the same syntax area may continue after the
	    " plain whitespace. But if it doesn't, we do not include the
	    " whitespace.
	elseif l:goodPosition != [0, 0]
	    " We've just left the syntax area.
	    break
	endif
	" Keep on searching for the next syntax area, until we wrap around and
	" arrive at the original position without a match.
    endwhile

    call setpos('.', [0] + (l:goodPosition == [0, 0] ? l:originalPosition : l:goodPosition) + [0])
    return l:goodPosition
endfunction
function! SameSyntaxMotion#Jump( count, SearchFunction, isBackward )
    let [l:currentSyntaxId, l:currentHlgroupId] = s:GetCurrentSyntaxAndHlgroupIds()
    return  CountJump#CountJumpFuncWithWrapMessage(a:count, 'same syntax search', a:isBackward, a:SearchFunction, l:currentSyntaxId, l:currentHlgroupId, (a:isBackward ? 'b' : ''), 0)
endfunction

function! SameSyntaxMotion#BeginForward( mode )
    call CountJump#JumpFunc(a:mode, function('SameSyntaxMotion#Jump'), function('SameSyntaxMotion#SearchFirstOfSynID'), 0)
endfunction
function! SameSyntaxMotion#BeginBackward( mode )
    call CountJump#JumpFunc(a:mode, function('SameSyntaxMotion#Jump'), function('SameSyntaxMotion#SearchLastOfSynID'), 1)
endfunction
function! SameSyntaxMotion#EndForward( mode )
    call CountJump#JumpFunc(a:mode, function('SameSyntaxMotion#Jump'), function('SameSyntaxMotion#SearchLastOfSynID'), 0)
endfunction
function! SameSyntaxMotion#EndBackward( mode )
    call CountJump#JumpFunc(a:mode, function('SameSyntaxMotion#Jump'), function('SameSyntaxMotion#SearchFirstOfSynID'), 1)
endfunction

function! SameSyntaxMotion#TextObjectBegin( count, isInner )
    let [g:CountJump_Context.syntaxId, g:CountJump_Context.hlgroupId] = s:GetCurrentSyntaxAndHlgroupIds()

    " Move one character to the right, so that we do not jump to the previous
    " syntax area when we're at the start of a syntax area. CountJump will
    " restore the original cursor position should there be no proper text
    " object.
    call search('.', 'W')

    return CountJump#CountJumpFunc(a:count, function('SameSyntaxMotion#SearchLastOfSynID'), g:CountJump_Context.syntaxId, g:CountJump_Context.hlgroupId, 'bW', a:isInner)
endfunction
function! SameSyntaxMotion#TextObjectEnd( count, isInner )
    return CountJump#CountJumpFunc(a:count, function('SameSyntaxMotion#SearchLastOfSynID'), g:CountJump_Context.syntaxId, g:CountJump_Context.hlgroupId, 'W' , a:isInner)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
