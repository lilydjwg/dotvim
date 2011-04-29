" Script Name: mark.vim
" Description: Highlight several words in different colors simultaneously. 
"
" Copyright:   (C) 2005-2008 by Yuheng Xie
"              (C) 2008-2011 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:  Ingo Karkat <ingo@karkat.de> 
"
" Dependencies:
"  - SearchSpecial.vim autoload script (optional, for improved search messages). 
"
" Version:     2.4.4
" Changes:
" 18-Apr-2011, Ingo Karkat
" - BUG: Include trailing newline character in check for current mark, so that a
"   mark that matches the entire line (e.g. created by V<Leader>m) can be
"   cleared via <Leader>n. Thanks to ping for reporting this. 
" - Minor restructuring of mark#MarkCurrentWord(). 
" - FIX: On overlapping marks, mark#CurrentMark() returned the lowest, not the
"   highest visible mark. So on overlapping marks, the one that was not visible
"   at the cursor position was removed; very confusing! Use reverse iteration
"   order.  
" - FIX: To avoid an arbitrary ordering of highlightings when the highlighting
"   group names roll over, and to avoid order inconsistencies across different
"   windows and tabs, we assign a different priority based on the highlighting
"   group. 
" - Rename s:cycleMax to s:markNum; the previous name was too
"   implementation-focused and off-by-one with regards to the actual value. 
"
" 16-Apr-2011, Ingo Karkat
" - Move configuration variable g:mwHistAdd to plugin/mark.vim (as is customary)
"   and make the remaining g:mw... variables script-local, as these contain
"   internal housekeeping information that does not need to be accessible by the
"   user. 
"
" 15-Apr-2011, Ingo Karkat
" - Robustness: Move initialization of w:mwMatch from mark#UpdateMark() to
"   s:MarkMatch(), where the variable is actually used. I had encountered cases
"   where it w:mwMatch was undefined when invoked through mark#DoMark() ->
"   s:MarkScope() -> s:MarkMatch(). This can be forced by :unlet w:mwMatch
"   followed by :Mark foo. 
" - Robustness: Checking for s:markNum == 0 in mark#DoMark(), trying to
"   re-detect the mark highlightings and finally printing an error instead of
"   choking. This can happen when somehow no mark highlightings are defined. 
"
" 14-Jan-2011, Ingo Karkat
" - FIX: Capturing the visual selection could still clobber the blockwise yank
"   mode of the unnamed register. 
"
" 13-Jan-2011, Ingo Karkat
" - FIX: Using a named register for capturing the visual selection on
"   {Visual}<Leader>m and {Visual}<Leader>r clobbered the unnamed register. Now
"   using the unnamed register. 
"
" 13-Jul-2010, Ingo Karkat
" - ENH: The MarkSearch mappings (<Leader>[*#/?]) add the original cursor
"   position to the jump list, like the built-in [/?*#nN] commands. This allows
"   to use the regular jump commands for mark matches, like with regular search
"   matches. 
"
" 19-Feb-2010, Andy Wokula
" - BUG: Clearing of an accidental zero-width match (e.g. via :Mark \zs) results
"   in endless loop. Thanks to Andy Wokula for the patch. 
"
" 17-Nov-2009, Ingo Karkat + Andy Wokula
" - BUG: Creation of literal pattern via '\V' in {Visual}<Leader>m mapping
"   collided with individual escaping done in <Leader>m mapping so that an
"   escaped '\*' would be interpreted as a multi item when both modes are used
"   for marking. Replaced \V with s:EscapeText() to be consistent. Replaced the
"   (overly) generic mark#GetVisualSelectionEscaped() with
"   mark#GetVisualSelectionAsRegexp() and
"   mark#GetVisualSelectionAsLiteralPattern(). Thanks to Andy Wokula for the
"   patch. 
"
" 06-Jul-2009, Ingo Karkat
" - Re-wrote s:AnyMark() in functional programming style. 
" - Now resetting 'smartcase' before the search, this setting should not be
"   considered for *-command-alike searches and cannot be supported because all
"   mark patterns are concatenated into one large regexp, anyway. 
"
" 04-Jul-2009, Ingo Karkat
" - Re-wrote s:Search() to handle v:count: 
"   - Obsoleted s:current_mark_position; mark#CurrentMark() now returns both the
"     mark text and start position. 
"   - s:Search() now checks for a jump to the current mark during a backward
"     search; this eliminates a lot of logic at its calling sites. 
"   - Reverted negative logic at calling sites; using empty() instead of != "". 
"   - Now passing a:isBackward instead of optional flags into s:Search() and
"     around its callers. 
"   - ':normal! zv' moved from callers into s:Search(). 
" - Removed delegation to SearchSpecial#ErrorMessage(), because the fallback
"   implementation is perfectly fine and the SearchSpecial routine changed its
"   output format into something unsuitable anyway. 
" - Using descriptive text instead of "@" (and appropriate highlighting) when
"   querying for the pattern to mark. 
"
" 02-Jul-2009, Ingo Karkat
" - Split off functions into autoload script. 

"- functions ------------------------------------------------------------------
function! s:EscapeText( text )
	return substitute( escape(a:text, '\' . '^$.*[~'), "\n", '\\n', 'ge' )
endfunction
" Mark the current word, like the built-in star command. 
" If the cursor is on an existing mark, remove it. 
function! mark#MarkCurrentWord()
	let l:regexp = mark#CurrentMark()[0]
	if empty(l:regexp)
		let l:cword = expand('<cword>')
		if ! empty(l:cword)
			let l:regexp = s:EscapeText(l:cword)
			" The star command only creates a \<whole word\> search pattern if the
			" <cword> actually only consists of keyword characters. 
			if l:cword =~# '^\k\+$'
				let l:regexp = '\<' . l:regexp . '\>'
			endif
		endif
	endif

	if ! empty(l:regexp)
		call mark#DoMark(l:regexp)
	endif
endfunction

function! s:GetVisualSelection()
	let save_clipboard = &clipboard
	set clipboard= " Avoid clobbering the selection and clipboard registers. 
	let save_reg = getreg('"')
	let save_regmode = getregtype('"')
	silent normal! gvy
	let res = getreg('"')
	call setreg('"', save_reg, save_regmode)
	let &clipboard = save_clipboard
	return res
endfunction
function! mark#GetVisualSelectionAsLiteralPattern()
	return s:EscapeText(s:GetVisualSelection())
endfunction
function! mark#GetVisualSelectionAsRegexp()
	return substitute(s:GetVisualSelection(), '\n', '', 'g')
endfunction

" Manually input a regular expression. 
function! mark#MarkRegex( regexpPreset )
	call inputsave()
	echohl Question
	let l:regexp = input('Input pattern to mark: ', a:regexpPreset)
	echohl None
	call inputrestore()
	if ! empty(l:regexp)
		call mark#DoMark(l:regexp)
	endif
endfunction

function! s:Cycle( ... )
	let l:currentCycle = s:cycle
	let l:newCycle = (a:0 ? a:1 : s:cycle) + 1
	let s:cycle = (l:newCycle < s:markNum ? l:newCycle : 0)
	return l:currentCycle
endfunction

" Set match / clear matches in the current window. 
function! s:MarkMatch( indices, expr )
	if ! exists('w:mwMatch')
		let w:mwMatch = repeat([0], s:markNum)
	endif

	for l:index in a:indices
		if w:mwMatch[l:index] > 0
			silent! call matchdelete(w:mwMatch[l:index])
			let w:mwMatch[l:index] = 0
		endif
	endfor

	if ! empty(a:expr)
		let l:index = a:indices[0]	" Can only set one index for now. 

		" Info: matchadd() does not consider the 'magic' (it's always on),
		" 'ignorecase' and 'smartcase' settings. 
		" Make the match according to the 'ignorecase' setting, like the star command. 
		" (But honor an explicit case-sensitive regexp via the /\C/ atom.) 
		let l:expr = ((&ignorecase && a:expr !~# '\\\@<!\\C') ? '\c' . a:expr : a:expr)

		" To avoid an arbitrary ordering of highlightings, we assign a different
		" priority based on the highlighting group, and ensure that the highest
		" priority is -10, so that we do not override the 'hlsearch' of 0, and still
		" allow other custom highlightings to sneak in between. 
		let l:priority = -10 - s:markNum + 1 + l:index

		let w:mwMatch[l:index] = matchadd('MarkWord' . (l:index + 1), l:expr, l:priority)
	endif
endfunction
" Set / clear matches in all windows. 
function! s:MarkScope( indices, expr )
	let l:currentWinNr = winnr()

	" By entering a window, its height is potentially increased from 0 to 1 (the
	" minimum for the current window). To avoid any modification, save the window
	" sizes and restore them after visiting all windows. 
	let l:originalWindowLayout = winrestcmd() 

	noautocmd windo call s:MarkMatch(a:indices, a:expr)
	execute l:currentWinNr . 'wincmd w'
	silent! execute l:originalWindowLayout
endfunction
" Update matches in all windows. 
function! mark#UpdateScope()
	let l:currentWinNr = winnr()

	" By entering a window, its height is potentially increased from 0 to 1 (the
	" minimum for the current window). To avoid any modification, save the window
	" sizes and restore them after visiting all windows. 
	let l:originalWindowLayout = winrestcmd() 

	noautocmd windo call mark#UpdateMark()
	execute l:currentWinNr . 'wincmd w'
	silent! execute l:originalWindowLayout
endfunction
" Mark or unmark a regular expression. 
function! mark#DoMark(...) " DoMark(regexp)
	let regexp = (a:0 ? a:1 : '')

	" clear all marks if regexp is null
	if empty(regexp)
		let i = 0
		let indices = []
		while i < s:markNum
			if !empty(s:pattern[i])
				let s:pattern[i] = ''
				call add(indices, i)
			endif
			let i += 1
		endwhile
		let s:lastSearch = ""
		call s:MarkScope(l:indices, '')
		return
	endif

	" clear the mark if it has been marked
	let i = 0
	while i < s:markNum
		if regexp == s:pattern[i]
			if s:lastSearch == s:pattern[i]
				let s:lastSearch = ''
			endif
			let s:pattern[i] = ''
			call s:MarkScope([i], '')
			return
		endif
		let i += 1
	endwhile

	if s:markNum <= 0
		" Uh, somehow no mark highlightings were defined. Try to detect them again. 
		call s:InitMarkVariables()
		if s:markNum <= 0
			" Still no mark highlightings; complain. 
			let v:errmsg = 'No mark highlightings defined'
			echohl ErrorMsg
			echomsg v:errmsg
			echohl None
			return
		endif
	endif

	" add to history
	if stridx(g:mwHistAdd, '/') >= 0
		call histadd('/', regexp)
	endif
	if stridx(g:mwHistAdd, '@') >= 0
		call histadd('@', regexp)
	endif

	" choose an unused mark group
	let i = 0
	while i < s:markNum
		if empty(s:pattern[i])
			let s:pattern[i] = regexp
			call s:Cycle(i)
			call s:MarkScope([i], regexp)
			return
		endif
		let i += 1
	endwhile

	" choose a mark group by cycle
	let i = s:Cycle()
	if s:lastSearch == s:pattern[i]
		let s:lastSearch = ''
	endif
	let s:pattern[i] = regexp
	call s:MarkScope([i], regexp)
endfunction
" Initialize mark colors in a (new) window. 
function! mark#UpdateMark()
	let i = 0
	while i < s:markNum
		if empty(s:pattern[i])
			call s:MarkMatch([i], '')
		else
			call s:MarkMatch([i], s:pattern[i])
		endif
		let i += 1
	endwhile
endfunction

" Return [mark text, mark start position] of the mark under the cursor (or
" ['', []] if there is no mark). 
" The mark can include the trailing newline character that concludes the line,
" but marks that span multiple lines are not supported. 
function! mark#CurrentMark()
	let line = getline('.') . "\n"

	" Highlighting groups with higher numbers take precedence over lower numbers,
	" and therefore its marks appear "above" other marks. To retrieve the visible
	" mark in case of overlapping marks, we need to check from highest to lowest
	" highlighting group. 
	let i = s:markNum - 1
	while i >= 0
		if ! empty(s:pattern[i])
			" Note: col() is 1-based, all other indexes zero-based! 
			let start = 0
			while start >= 0 && start < strlen(line) && start < col('.')
				let b = match(line, s:pattern[i], start)
				let e = matchend(line, s:pattern[i], start)
				if b < col('.') && col('.') <= e
					return [s:pattern[i], [line('.'), (b + 1)]]
				endif
				if b == e
					break
				endif
				let start = e
			endwhile
		endif
		let i -= 1
	endwhile
	return ['', []]
endfunction

" Search current mark. 
function! mark#SearchCurrentMark( isBackward )
	let [l:markText, l:markPosition] = mark#CurrentMark()
	if empty(l:markText)
		if empty(s:lastSearch)
			call mark#SearchAnyMark(a:isBackward)
			let s:lastSearch = mark#CurrentMark()[0]
		else
			call s:Search(s:lastSearch, a:isBackward, [], 'same-mark')
		endif
	else
		call s:Search(l:markText, a:isBackward, l:markPosition, (l:markText ==# s:lastSearch ? 'same-mark' : 'new-mark'))
		let s:lastSearch = l:markText
	endif
endfunction

silent! call SearchSpecial#DoesNotExist()	" Execute a function to force autoload.  
if exists('*SearchSpecial#WrapMessage')
	function! s:WrapMessage( searchType, searchPattern, isBackward )
		redraw
		call SearchSpecial#WrapMessage(a:searchType, a:searchPattern, a:isBackward)
	endfunction
	function! s:EchoSearchPattern( searchType, searchPattern, isBackward )
		call SearchSpecial#EchoSearchPattern(a:searchType, a:searchPattern, a:isBackward)
	endfunction
else
	function! s:Trim( message )
		" Limit length to avoid "Hit ENTER" prompt. 
		return strpart(a:message, 0, (&columns / 2)) . (len(a:message) > (&columns / 2) ? "..." : "")
	endfunction
	function! s:WrapMessage( searchType, searchPattern, isBackward )
		redraw
		let v:warningmsg = printf('%s search hit %s, continuing at %s', a:searchType, (a:isBackward ? 'TOP' : 'BOTTOM'), (a:isBackward ? 'BOTTOM' : 'TOP'))
		echohl WarningMsg
		echo s:Trim(v:warningmsg)
		echohl None
	endfunction
	function! s:EchoSearchPattern( searchType, searchPattern, isBackward )
		let l:message = (a:isBackward ? '?' : '/') .  a:searchPattern
		echohl SearchSpecialSearchType
		echo a:searchType
		echohl None
		echon s:Trim(l:message)
	endfunction
endif
function! s:ErrorMessage( searchType, searchPattern, isBackward )
	if &wrapscan
		let v:errmsg = a:searchType . ' not found: ' . a:searchPattern
	else
		let v:errmsg = printf('%s search hit %s without match for: %s', a:searchType, (a:isBackward ? 'TOP' : 'BOTTOM'), a:searchPattern)
	endif
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
endfunction

" Wrapper around search() with additonal search and error messages and "wrapscan" warning. 
function! s:Search( pattern, isBackward, currentMarkPosition, searchType )
	let l:save_view = winsaveview()

	" searchpos() obeys the 'smartcase' setting; however, this setting doesn't
	" make sense for the mark search, because all patterns for the marks are
	" concatenated as branches in one large regexp, and because patterns that
	" result from the *-command-alike mappings should not obey 'smartcase' (like
	" the * command itself), anyway. If the :Mark command wants to support
	" 'smartcase', it'd have to emulate that into the regular expression. 
	let l:save_smartcase = &smartcase
	set nosmartcase

	let l:count = v:count1
	let [l:startLine, l:startCol] = [line('.'), col('.')]
	let l:isWrapped = 0
	let l:isMatch = 0
	let l:line = 0
	while l:count > 0
		" Search for next match, 'wrapscan' applies. 
		let [l:line, l:col] = searchpos( a:pattern, (a:isBackward ? 'b' : '') )

"****D echomsg '****' a:isBackward string([l:line, l:col]) string(a:currentMarkPosition) l:count
		if a:isBackward && l:line > 0 && [l:line, l:col] == a:currentMarkPosition && l:count == v:count1
			" On a search in backward direction, the first match is the start of the
			" current mark (if the cursor was positioned on the current mark text, and
			" not at the start of the mark text). 
			" In contrast to the normal search, this is not considered the first
			" match. The mark text is one entity; if the cursor is positioned anywhere
			" inside the mark text, the mark text is considered the current mark. The
			" built-in '*' and '#' commands behave in the same way; the entire <cword>
			" text is considered the current match, and jumps move outside that text.
			" In normal search, the cursor can be positioned anywhere (via offsets)
			" around the search, and only that single cursor position is considered
			" the current match. 
			" Thus, the search is retried without a decrease of l:count, but only if
			" this was the first match; repeat visits during wrapping around count as
			" a regular match. The search also must not be retried when this is the
			" first match, but we've been here before (i.e. l:isMatch is set): This
			" means that there is only the current mark in the buffer, and we must
			" break out of the loop and indicate that no other mark was found. 
			if l:isMatch
				let l:line = 0
				break
			endif

			" The l:isMatch flag is set so if the final mark cannot be reached, the
			" original cursor position is restored. This flag also allows us to detect
			" whether we've been here before, which is checked above. 
			let l:isMatch = 1
		elseif l:line > 0
			let l:isMatch = 1
			let l:count -= 1

			" Note: No need to check 'wrapscan'; the wrapping can only occur if
			" 'wrapscan' is actually on. 
			if ! a:isBackward && (l:startLine > l:line || l:startLine == l:line && l:startCol >= l:col)
				let l:isWrapped = 1
			elseif a:isBackward && (l:startLine < l:line || l:startLine == l:line && l:startCol <= l:col)
				let l:isWrapped = 1
			endif
		else
			break
		endif
	endwhile
	let &smartcase = l:save_smartcase
	
	" We're not stuck when the search wrapped around and landed on the current
	" mark; that's why we exclude a possible wrap-around via v:count1 == 1. 
	let l:isStuckAtCurrentMark = ([l:line, l:col] == a:currentMarkPosition && v:count1 == 1)
	if l:line > 0 && ! l:isStuckAtCurrentMark
		let l:matchPosition = getpos('.')

		" Open fold at the search result, like the built-in commands. 
		normal! zv

		" Add the original cursor position to the jump list, like the
		" [/?*#nN] commands. 
		" Implementation: Memorize the match position, restore the view to the state
		" before the search, then jump straight back to the match position. This
		" also allows us to set a jump only if a match was found. (:call
		" setpos("''", ...) doesn't work in Vim 7.2) 
		call winrestview(l:save_view)
		normal! m'
		call setpos('.', l:matchPosition)

		if l:isWrapped
			call s:WrapMessage(a:searchType, a:pattern, a:isBackward)
		else
			call s:EchoSearchPattern(a:searchType, a:pattern, a:isBackward)
		endif
		return 1
	else
		if l:isMatch
			" The view has been changed by moving through matches until the end /
			" start of file, when 'nowrapscan' forced a stop of searching before the
			" l:count'th match was found. 
			" Restore the view to the state before the search. 
			call winrestview(l:save_view)
		endif
		call s:ErrorMessage(a:searchType, a:pattern, a:isBackward)
		return 0
	endif
endfunction

" Combine all marks into one regexp. 
function! s:AnyMark()
	return join(filter(copy(s:pattern), '! empty(v:val)'), '\|')
endfunction

" Search any mark. 
function! mark#SearchAnyMark( isBackward )
	let l:markPosition = mark#CurrentMark()[1]
	let l:markText = s:AnyMark()
	call s:Search(l:markText, a:isBackward, l:markPosition, 'any-mark')
	let s:lastSearch = ""
endfunction

" Search last searched mark. 
function! mark#SearchNext( isBackward )
	let l:markText = mark#CurrentMark()[0]
	if empty(l:markText)
		return 0
	else
		if empty(s:lastSearch)
			call mark#SearchAnyMark(a:isBackward)
		else
			call mark#SearchCurrentMark(a:isBackward)
		endif
		return 1
	endif
endfunction

"- initializations ------------------------------------------------------------
augroup Mark
	autocmd!
	autocmd VimEnter * if ! exists('w:mwMatch') | call mark#UpdateMark() | endif
	autocmd WinEnter * if ! exists('w:mwMatch') | call mark#UpdateMark() | endif
	autocmd TabEnter * call mark#UpdateScope()
augroup END

" Define global variables and initialize current scope.  
function! s:InitMarkVariables()
	let s:markNum = 0
	while hlexists('MarkWord' . (s:markNum + 1))
		let s:markNum += 1
	endwhile
	let s:cycle = 0
	let s:pattern = repeat([''], s:markNum)
	let s:lastSearch = ""
endfunction
call s:InitMarkVariables()
call mark#UpdateScope()

" vim: ts=2 sw=2
