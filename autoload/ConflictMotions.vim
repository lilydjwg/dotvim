" ConflictMotions.vim: Motions to and inside SCM conflict markers.
"
" DEPENDENCIES:
"   - ingo/lines.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   2.00.003	04-Apr-2013	Move ingolines#PutWrapper() into ingo-library.
"   2.00.002	31-Oct-2012	Implement iteration over all markers in the
"				passed range.
"   2.00.001	30-Oct-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ConflictMotions#Complete( ArgLead, CmdLine, CursorPos )
    return filter(['none', 'this', 'ours', 'base', 'theirs', 'both', 'all', 'range', '-', '.', '<', '|', '>', '+', '*', ':'], 'v:val =~ "\\V" . escape(a:ArgLead, "\\")')
endfunction
function! s:CanonicalizeArguments( arguments, startLnum, endLnum )
    let l:result = []
    for l:what in a:arguments
	if l:what ==? 'both' || l:what ==# '+'
	    let l:result += ['ours', 'theirs']
	elseif l:what ==? 'all' || l:what ==# '*'
	    " The base section is optional; only capture it when it's there.
	    if search('^|\{7}|\@!', 'nW', a:endLnum)
		let l:result += ['ours', 'base', 'theirs']
	    else
		let l:result += ['ours', 'theirs']
	    endif
	else
	    call add(l:result, l:what)
	endif
    endfor

    return l:result
endfunction
function! s:ErrorMsg( text, isBeep )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None

    if a:isBeep
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    endif
endfunction
function! s:EchoQuestion( conflictCnt )
    echohl Question
    echo (a:conflictCnt > 0 ? printf('#%d ', a:conflictCnt) : '') .
    \   'take: (/,s)kip, (-,n)one (<,o)urs (|,b)ase (>,t)heirs (+)bot(h) (*,a)ll (q)uit/^E/^Y ?'
    echohl None
endfunction
function! s:Query( conflictCnt, startLnum, endLnum )
    if ! empty(s:stickyChoice)
	return s:stickyChoice
    endif

    " If possible, show the entire conflict (in the middle) of the window.
    let l:padding = (winheight(0) - a:endLnum + a:startLnum - 1) / 2
    let l:firstVisibleLnum = max([1, a:startLnum - max([0, l:padding])])
    execute 'normal!' l:firstVisibleLnum . 'zt'
    call cursor(a:startLnum, 1) " Restore the cursor to the start of the current conflict.

    if exists('*matchadd')
	let l:id = matchadd('IncSearch', printf('\%%%dl\|\%%%dl', a:startLnum, a:endLnum))
    endif

    redraw
    call s:EchoQuestion(a:conflictCnt)
    while 1
	let l:choice = nr2char(getchar())
	if l:choice =~# "[\<C-e>\<C-y>]"
	    execute 'normal!' l:choice
	    redraw
	    call s:EchoQuestion(a:conflictCnt)
	elseif l:choice =~? '[-n/s<o|b>t+h*aq\e]'
	    let l:response =
	    \   {
	    \       '-': 'none',
	    \       'n': 'none',
	    \       '/': 'skip',
	    \       's': 'skip',
	    \       '<': 'ours',
	    \       'o': 'ours',
	    \       '|': 'base',
	    \       'b': 'base',
	    \       '>': 'theirs',
	    \       't': 'theirs',
	    \       '+': 'both',
	    \       'h': 'both',
	    \       '*': 'all',
	    \       'a': 'all',
	    \       'q': '',
	    \       "\<Esc>": ''
	    \}[tolower(l:choice)]

	    if l:choice =~# '\u'
		let s:stickyChoice = l:response
	    endif

	    if exists('*matchadd')
		call matchdelete(l:id)
	    endif

	    return l:response
	endif
    endwhile
endfunction
function! s:FindEndOfConflict()
    return search('^>\{7}>\@!', 'nW')
endfunction
function! s:GetCurrentConflict( currentLnum )
"******************************************************************************
"* PURPOSE:
"   This is a re-implementation of the
"   CountJump#TextObject#TextObjectWithJumpFunctions() that doesn't beep and
"   modify the visual selection.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Positions the cursor on the beginning of the conflict, if there is one.
"* INPUTS:
"   a:currentLnum   Current line number.
"* RETURN VALUES:
"   [startLnum, endLnum] if the cursor is inside a conflict, or [0, 0].
"******************************************************************************
    if ! search('^<\{7}<\@!', 'bcW')
	return [0, 0]
    endif

    let l:endLnum = s:FindEndOfConflict()
    if ! l:endLnum || l:endLnum < a:currentLnum
	return [0, 0]
    endif

    return [line('.'), l:endLnum]
endfunction
function! s:CaptureSection()
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
	silent execute printf('normal yi%s', g:ConflictMotions_SectionMapping)
	let l:section = @"
    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:section
endfunction
function! ConflictMotions#Take( takeStartLnum, takeEndLnum, arguments )
    let s:stickyChoice = ''
    let l:currentLnum = line('.')
    let l:save_view = winsaveview()
    let l:hasRange = (a:takeEndLnum != 1)

    let [l:startLnum, l:endLnum] = s:GetCurrentConflict(l:currentLnum)
    let l:isInsideConflict = (l:startLnum != 0 && l:endLnum != 0)

    if l:hasRange
	if l:isInsideConflict && a:takeStartLnum > l:startLnum && a:takeEndLnum < l:endLnum
	    " Take the selected lines from the current conflict.
	    call ConflictMotions#TakeFromConflict(0, l:currentLnum, l:startLnum, l:endLnum, a:arguments, 'this', 1, a:takeStartLnum, a:takeEndLnum)
	else
	    " Go through all conflicts found in the range.
	    let [l:takeStartLnum, l:takeEndLnum] = [a:takeStartLnum, a:takeEndLnum]
	    call cursor(l:takeStartLnum, 1)
	    let l:conflictCnt = 0
	    while l:startLnum <= l:takeEndLnum
		" For the finding the first conflict, allow match at the current position, too.
		let l:startLnum = search('^<\{7}<\@!', 'W' . (l:conflictCnt == 0 ? 'c' : ''), l:takeEndLnum)
		if l:startLnum == 0
		    break
		endif
		let l:endLnum = s:FindEndOfConflict()
		if l:endLnum == 0
		    break
		endif

		let l:conflictCnt += 1
		let l:offset = ConflictMotions#TakeFromConflict(l:conflictCnt, l:startLnum, l:startLnum, l:endLnum, a:arguments, 'query', 0, 0, 0)
		if l:offset == -1
		    break
		else
		    let l:takeEndLnum -= l:offset
		endif
	    endwhile

	    if l:conflictCnt == 0
		" Not a single conflict was found.
		call winrestview(l:save_view)
		call s:ErrorMsg(printf('No conflicts %s', (a:takeStartLnum == 1 && a:takeEndLnum == line('$') ? 'in buffer' : 'inside range')), 1)
	    endif
	endif
    elseif ! l:isInsideConflict
	" Capture failed; the cursor is not inside a conflict.
	call winrestview(l:save_view)
	call s:ErrorMsg('Not inside conflict', 1)
    else
	" Take from the current conflict.
	call ConflictMotions#TakeFromConflict(0, l:currentLnum, l:startLnum, l:endLnum, a:arguments, 'this', 0, 0, 0)
    endif
endfunction
function! ConflictMotions#TakeFromConflict( conflictCnt, currentLnum, startLnum, endLnum, arguments, defaultArgument, isKeepRange, takeStartLnum, takeEndLnum )
"****D echomsg '****' a:arguments a:isKeepRange a:startLnum a:endLnum
    if a:isKeepRange
	let l:rangeSection =
	\   join(
	\       filter(
	\           getline(a:takeStartLnum, a:takeEndLnum),
	\           'v:val !~# "^\\([<=>|]\\)\\{7}\\1\\@!"') + [''],
	\   "\n")
    endif

    let l:sections = ''
    let l:arguments = split(a:arguments, '\s\+\|\%(\A\&\S\)\zs')
    for l:what in (empty(a:arguments) && ! a:isKeepRange ?
    \   [a:defaultArgument] :
    \   s:CanonicalizeArguments(l:arguments, a:startLnum, a:endLnum) +
    \       (! a:isKeepRange || index(l:arguments, 'range', 0, 1) != -1 || index(l:arguments, ':') != -1 ? [] : ['range'])
    \)
	call cursor(a:startLnum, 1)

	let l:isFoundMarker = 0
	if l:what ==? 'skip' || l:what ==# '/'
	    call cursor(a:endLnum)
	    return 0
	elseif l:what ==? 'none' || l:what ==# '-'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'this' || l:what ==# '.'
	    let l:isFoundMarker = 1
	    call cursor(a:currentLnum, 1)
	elseif l:what ==? 'ours' || l:what ==# '<'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'base' || l:what ==# '|'
	    let l:isFoundMarker = search('^|\{7}|\@!', 'W')
	elseif l:what ==? 'theirs' || l:what ==# '>'
	    let l:isFoundMarker = search('^=\{7}=\@!', 'W')
	elseif l:what ==? 'range' || l:what ==# ':'
	    if a:isKeepRange
		let l:isFoundMarker = 1
	    else
		call cursor(a:currentLnum, 1)
		call s:ErrorMsg('No range given; invalid argument "' . l:what . '"', 0)
		return -1
	    endif
	elseif l:what ==? 'query' || l:what ==# '?'
	    let l:response = s:Query(a:conflictCnt, a:startLnum, a:endLnum)
	    if empty(l:response)
		return -1
	    else
		" Recurse with the arguments resolved by the user query.
		return ConflictMotions#TakeFromConflict(a:conflictCnt, a:currentLnum, a:startLnum, a:endLnum, l:response, '', a:isKeepRange, a:takeStartLnum, a:takeEndLnum)
	    endif
	else
	    call s:ErrorMsg('Invalid argument: ' . l:what, 0)
	    return -1
	endif

	if ! l:isFoundMarker
	    call cursor(a:startLnum, 1)
	    call s:ErrorMsg('Conflict marker not found', 1)
	    return -1
	endif

	if l:what ==? 'range' || l:what ==# ':'
	    let l:sections .= l:rangeSection
	elseif l:what !=? 'none' && l:what !=# '-'
	    let l:sections .= s:CaptureSection()
	endif
    endfor

    execute (empty(l:sections) ? '' : 'silent') printf('%d,%ddelete _', a:startLnum, a:endLnum)
    if empty(l:sections)
	return (a:endLnum - a:startLnum + 1)
    else
	let l:prevLineCnt = line('$')
	call ingo#lines#PutWrapper(a:startLnum, 'put!', l:sections)
	return (a:endLnum - a:startLnum + 1) - (line('$') - l:prevLineCnt)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
