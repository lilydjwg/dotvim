" Script Name: mark.vim
" Description: Highlight several words in different colors simultaneously. 
"
" Copyright:   (C) 2005-2008 by Yuheng Xie
"              (C) 2008-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:  Ingo Karkat <ingo@karkat.de> 
"
" Dependencies:
"  - SearchSpecial.vim autoload script (optional, for improved search messages). 
"
" Version:     2.4.0
" Changes:
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
		let l:cword = expand("<cword>")

		" The star command only creates a \<whole word\> search pattern if the
		" <cword> actually only consists of keyword characters. 
		if l:cword =~# '^\k\+$'
			let l:regexp = '\<' . s:EscapeText(l:cword) . '\>'
		elseif l:cword != ''
			let l:regexp = s:EscapeText(l:cword)
		endif
	endif

	if ! empty(l:regexp)
		call mark#DoMark(l:regexp)
	endif
endfunction

function! s:GetVisualSelection()
	let save_a = @a
	silent normal! gv"ay
	let res = @a
	let @a = save_a
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
	let l:currentCycle = g:mwCycle
	let l:newCycle = (a:0 ? a:1 : g:mwCycle) + 1
	let g:mwCycle = (l:newCycle < g:mwCycleMax ? l:newCycle : 0)
	return l:currentCycle
endfunction

" Set / clear matches in the current window. 
function! s:MarkMatch( indices, expr )
	for l:index in a:indices
		if w:mwMatch[l:index] > 0
			silent! call matchdelete(w:mwMatch[l:index])
			let w:mwMatch[l:index] = 0
		endif
	endfor

	if ! empty(a:expr)
		" Make the match according to the 'ignorecase' setting, like the star command. 
		" (But honor an explicit case-sensitive regexp via the /\C/ atom.) 
		let l:expr = ((&ignorecase && a:expr !~# '\\\@<!\\C') ? '\c' . a:expr : a:expr)

		" Info: matchadd() does not consider the 'magic' (it's always on),
		" 'ignorecase' and 'smartcase' settings. 
		let w:mwMatch[a:indices[0]] = matchadd('MarkWord' . (a:indices[0] + 1), l:expr, -10)
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
		while i < g:mwCycleMax
			if !empty(g:mwWord[i])
				let g:mwWord[i] = ''
				call add(indices, i)
			endif
			let i += 1
		endwhile
		let g:mwLastSearched = ""
		call s:MarkScope(l:indices, '')
		return
	endif

	" clear the mark if it has been marked
	let i = 0
	while i < g:mwCycleMax
		if regexp == g:mwWord[i]
			if g:mwLastSearched == g:mwWord[i]
				let g:mwLastSearched = ''
			endif
			let g:mwWord[i] = ''
			call s:MarkScope([i], '')
			return
		endif
		let i += 1
	endwhile

	" add to history
	if stridx(g:mwHistAdd, "/") >= 0
		call histadd("/", regexp)
	endif
	if stridx(g:mwHistAdd, "@") >= 0
		call histadd("@", regexp)
	endif

	" choose an unused mark group
	let i = 0
	while i < g:mwCycleMax
		if empty(g:mwWord[i])
			let g:mwWord[i] = regexp
			call s:Cycle(i)
			call s:MarkScope([i], regexp)
			return
		endif
		let i += 1
	endwhile

	" choose a mark group by cycle
	let i = s:Cycle()
	if g:mwLastSearched == g:mwWord[i]
		let g:mwLastSearched = ''
	endif
	let g:mwWord[i] = regexp
	call s:MarkScope([i], regexp)
endfunction
" Initialize mark colors in a (new) window. 
function! mark#UpdateMark()
	if ! exists('w:mwMatch')
		let w:mwMatch = repeat([0], g:mwCycleMax)
	endif

	let i = 0
	while i < g:mwCycleMax
		if empty(g:mwWord[i])
			call s:MarkMatch([i], '')
		else
			call s:MarkMatch([i], g:mwWord[i])
		endif
		let i += 1
	endwhile
endfunction

" Return [mark text, mark start position] of the mark under the cursor (or
" ['', []] if there is no mark); multi-lines marks not supported. 
function! mark#CurrentMark()
	let line = getline(".")
	let i = 0
	while i < g:mwCycleMax
		if !empty(g:mwWord[i])
			" Note: col() is 1-based, all other indexes zero-based! 
			let start = 0
			while start >= 0 && start < strlen(line) && start < col(".")
				let b = match(line, g:mwWord[i], start)
				let e = matchend(line, g:mwWord[i], start)
				if b < col(".") && col(".") <= e
					return [g:mwWord[i], [line("."), (b + 1)]]
				endif
				if b == e
					break
				endif
				let start = e
			endwhile
		endif
		let i += 1
	endwhile
	return ['', []]
endfunction

" Search current mark. 
function! mark#SearchCurrentMark( isBackward )
	let [l:markText, l:markPosition] = mark#CurrentMark()
	if empty(l:markText)
		if empty(g:mwLastSearched)
			call mark#SearchAnyMark(a:isBackward)
			let g:mwLastSearched = mark#CurrentMark()[0]
		else
			call s:Search(g:mwLastSearched, a:isBackward, [], 'same-mark')
		endif
	else
		call s:Search(l:markText, a:isBackward, l:markPosition, (l:markText ==# g:mwLastSearched ? 'same-mark' : 'new-mark'))
		let g:mwLastSearched = l:markText
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
	return join(filter(copy(g:mwWord), '! empty(v:val)'), '\|')
endfunction

" Search any mark. 
function! mark#SearchAnyMark( isBackward )
	let l:markPosition = mark#CurrentMark()[1]
	let l:markText = s:AnyMark()
	call s:Search(l:markText, a:isBackward, l:markPosition, 'any-mark')
	let g:mwLastSearched = ""
endfunction

" Search last searched mark. 
function! mark#SearchNext( isBackward )
	let l:markText = mark#CurrentMark()[0]
	if empty(l:markText)
		return 0
	else
		if empty(g:mwLastSearched)
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
	if !exists("g:mwHistAdd")
		let g:mwHistAdd = "/@"
	endif
	if !exists("g:mwCycleMax")
		let i = 1
		while hlexists("MarkWord" . i)
			let i = i + 1
		endwhile
		let g:mwCycleMax = i - 1
	endif
	if !exists("g:mwCycle")
		let g:mwCycle = 0
	endif
	if !exists("g:mwWord")
		let g:mwWord = repeat([''], g:mwCycleMax)
	endif
	if !exists("g:mwLastSearched")
		let g:mwLastSearched = ""
	endif
endfunction
call s:InitMarkVariables()
call mark#UpdateScope()

" vim: ts=2 sw=2
