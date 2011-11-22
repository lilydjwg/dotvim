" Script Name: mark.vim
" Description: Highlight several words in different colors simultaneously. 
"
" Copyright:   (C) 2005-2008 by Yuheng Xie
"              (C) 2008-2011 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:  Ingo Karkat <ingo@karkat.de> 
" Orig Author: Yuheng Xie <elephant@linux.net.cn>
" Contributors:Luc Hermitte, Ingo Karkat
"
" Dependencies:
"  - Requires Vim 7.1 with "matchadd()", or Vim 7.2 or higher. 
"  - mark.vim autoload script. 
" 
" Version:     2.5.0
" Changes:
" 06-May-2011, Ingo Karkat
" - By default, enable g:mwAutoSaveMarks, so that marks are always persisted,
"   but disable g:mwAutoLoadMarks, so that persisted marks have to be explicitly
"   loaded, if that is desired. I often wondered why I got unexpected mark
"   highlightings in a new Vim session until I realized that I had used marks in
"   a previous session and forgot to clear them. 
"
" 21-Apr-2011, Ingo Karkat
" - Expose toggling of mark display (keeping the mark patterns) via new
"   <Plug>MarkToggle mapping. Offer :MarkClear command as a replacement for the
"   old argumentless :Mark command, which now just disables, but not clears all
"   marks. 
" - Implement lazy-loading of disabled persistent marks via g:mwDoDeferredLoad
"   flag passing to autoload/mark.vim. 
"
" 19-Apr-2011, Ingo Karkat
" - ENH: Add explicit mark persistence via :MarkLoad and :MarkSave commands and
"   automatic persistence via the g:mwAutoLoadMarks and g:mwAutoSaveMarks
"   configuration flags. 
"
" 15-Apr-2011, Ingo Karkat
" - Avoid losing the mark highlightings on :syn on or :colorscheme commands.
"   Thanks to Zhou YiChao for alerting me to this issue and suggesting a fix. 
"
" 17-Nov-2009, Ingo Karkat
" - Replaced the (overly) generic mark#GetVisualSelectionEscaped() with
"   mark#GetVisualSelectionAsRegexp() and
"   mark#GetVisualSelectionAsLiteralPattern(). 
"
" 04-Jul-2009, Ingo Karkat
" - A [count] before any mapping either caused "No range allowed" error or just
"   repeated the :call [count] times, resulting in the current search pattern
"   echoed [count] times and a hit-enter prompt. Now suppressing [count] via
"   <C-u> and handling it inside the implementation. 
" - Now passing isBackward (0/1) instead of optional 'b' flag into functions. 
"   Also passing empty regexp to mark#MarkRegex() to avoid any optional
"   arguments. 
"
" 02-Jul-2009, Ingo Karkat
" - Split off functions into autoload script. 
" - Removed g:force_reload_mark. 
" - Initialization of global variables and autocommands is now done lazily on
"   the first use, not during loading of the plugin. This reduces Vim startup
"   time and footprint as long as the functionality isn't yet used. 
"
" 6-Jun-2009, Ingo Karkat
"  1. Somehow s:WrapMessage() needs a redraw before the :echo to avoid that a
"     later Vim redraw clears the wrap message. This happened when there's no
"     statusline and thus :echo'ing into the ruler. 
"  2. Removed line-continuations and ':set cpo=...'. Upper-cased <SID> and <CR>. 
"  3. Added default highlighting for the special search type. 
"
" 2-Jun-2009, Ingo Karkat
"  1. Replaced highlighting via :syntax with matchadd() / matchdelete(). This
"     requires Vim 7.2 / 7.1 with patches. This method is faster, there are no
"     more clashes with syntax highlighting (:match always has preference), and
"     the background highlighting does not disappear under 'cursorline'. 
"  2. Factored :windo application out into s:MarkScope(). 
"  3. Using winrestcmd() to fix effects of :windo: By entering a window, its
"     height is potentially increased from 0 to 1. 
"  4. Handling multiple tabs by calling s:UpdateScope() on the TabEnter event. 
"     
" 1-Jun-2009, Ingo Karkat
"  1. Now using Vim List for g:mwWord and thus requiring Vim 7. g:mwCycle is now
"     zero-based, but the syntax groups "MarkWordx" are still one-based. 
"  2. Added missing setter for re-inclusion guard. 
"  3. Factored :syntax operations out of s:DoMark() and s:UpdateMark() so that
"     they can all be done in a single :windo. 
"  4. Normal mode <Plug>MarkSet now has the same semantics as its visual mode
"     cousin: If the cursor is on an existing mark, the mark is removed.
"     Beforehand, one could only remove a visually selected mark via again
"     selecting it. Now, one simply can invoke the mapping when on such a mark. 
"  5. Highlighting can now actually be overridden in the vimrc (anywhere
"     _before_ sourcing this script) by using ':hi def'. 
"
" 31-May-2009, Ingo Karkat
"  1. Refactored s:Search() to optionally take advantage of SearchSpecial.vim
"     autoload functionality for echoing of search pattern, wrap and error
"     messages. 
"  2. Now prepending search type ("any-mark", "same-mark", "new-mark") for
"     better identification. 
"  3. Retired the algorithm in s:PrevWord in favor of simply using <cword>,
"     which makes mark.vim work like the * command. At the end of a line,
"     non-keyword characters may now be marked; the previous algorithm prefered
"     any preceding word. 
"  4. BF: If 'iskeyword' contains characters that have a special meaning in a
"     regex (e.g. [.*]), these are now escaped properly. 
"
" 01-Sep-2008, Ingo Karkat: bugfixes and enhancements
"  1. Added <Plug>MarkAllClear (without a default mapping), which clears all
"     marks, even when the cursor is on a mark.
"  2. Added <Plug>... mappings for hard-coded \*, \#, \/, \?, * and #, to allow
"     re-mapping and disabling. Beforehand, there were some <Plug>... mappings
"     and hard-coded ones; now, everything can be customized.
"  3. Bugfix: Using :autocmd without <bang> to avoid removing _all_ autocmds for
"     the BufWinEnter event. (Using a custom :augroup would be even better.)
"  4. Bugfix: Explicitly defining s:current_mark_position; some execution paths
"     left it undefined, causing errors.
"  5. Refactoring: Instead of calling s:InitMarkVariables() at the beginning of
"     several functions, just calling it once when sourcing the script.
"  6. Refactoring: Moved multiple 'let lastwinnr = winnr()' to a single one at the
"     top of DoMark().
"  7. ENH: Make the match according to the 'ignorecase' setting, like the star
"     command.
"  8. The jumps to the next/prev occurrence now print 'search hit BOTTOM,
"     continuing at TOP" and "Pattern not found:..." messages, like the * and
"     n/N Vim search commands.
"  9. Jumps now open folds if the occurrence is inside a closed fold, just like n/N
"     do. 
"
" 10th Mar 2006, Yuheng Xie: jump to ANY mark
" (*) added \* \# \/ \? for the ability of jumping to ANY mark, even when the
"     cursor is not currently over any mark
"
" 20th Sep 2005, Yuheng Xie: minor modifications
" (*) merged MarkRegexVisual into MarkRegex
" (*) added GetVisualSelectionEscaped for multi-lines visual selection and
"     visual selection contains ^, $, etc.
" (*) changed the name ThisMark to CurrentMark
" (*) added SearchCurrentMark and re-used raw map (instead of Vim function) to
"     implement * and #
"
" 14th Sep 2005, Luc Hermitte: modifications done on v1.1.4
" (*) anti-reinclusion guards. They do not guard colors definitions in case
"     this script must be reloaded after .gvimrc
" (*) Protection against disabled |line-continuation|s.
" (*) Script-local functions
" (*) Default keybindings
" (*) \r for visual mode
" (*) uses <Leader> instead of "\"
" (*) do not mess with global variable g:w
" (*) regex simplified -> double quotes changed into simple quotes.
" (*) strpart(str, idx, 1) -> str[idx]
" (*) command :Mark
"     -> e.g. :Mark Mark.\{-}\ze(

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_mark') || (v:version == 701 && ! exists('*matchadd')) || (v:version < 702)
	finish
endif
let g:loaded_mark = 1

"- configuration --------------------------------------------------------------
if ! exists('g:mwHistAdd')
	let g:mwHistAdd = '/@'
endif

if ! exists('g:mwAutoLoadMarks')
	let g:mwAutoLoadMarks = 0
endif

if ! exists('g:mwAutoSaveMarks')
	let g:mwAutoSaveMarks = 1
endif


"- default highlightings ------------------------------------------------------
function! s:DefaultHighlightings()
	" You may define your own colors in your vimrc file, in the form as below:
	highlight def MarkWord1  ctermbg=Cyan     ctermfg=Black  guibg=#8CCBEA    guifg=Black
	highlight def MarkWord2  ctermbg=Green    ctermfg=Black  guibg=#A4E57E    guifg=Black
	highlight def MarkWord3  ctermbg=Yellow   ctermfg=Black  guibg=#FFDB72    guifg=Black
	highlight def MarkWord4  ctermbg=Red      ctermfg=Black  guibg=#FF7272    guifg=Black
	highlight def MarkWord5  ctermbg=Magenta  ctermfg=Black  guibg=#FFB3FF    guifg=Black
	highlight def MarkWord6  ctermbg=Blue     ctermfg=Black  guibg=#9999FF    guifg=Black
endfunction
call s:DefaultHighlightings()
autocmd ColorScheme * call <SID>DefaultHighlightings()

" Default highlighting for the special search type. 
" You can override this by defining / linking the 'SearchSpecialSearchType'
" highlight group before this script is sourced. 
highlight def link SearchSpecialSearchType MoreMsg


"- mappings -------------------------------------------------------------------
nnoremap <silent> <Plug>MarkSet   :<C-u>call mark#MarkCurrentWord()<CR>
vnoremap <silent> <Plug>MarkSet   <C-\><C-n>:call mark#DoMark(mark#GetVisualSelectionAsLiteralPattern())<CR>
nnoremap <silent> <Plug>MarkRegex :<C-u>call mark#MarkRegex('')<CR>
vnoremap <silent> <Plug>MarkRegex <C-\><C-n>:call mark#MarkRegex(mark#GetVisualSelectionAsRegexp())<CR>
nnoremap <silent> <Plug>MarkClear :<C-u>call mark#DoMark(mark#CurrentMark()[0])<CR>
nnoremap <silent> <Plug>MarkAllClear :<C-u>call mark#ClearAll()<CR>
nnoremap <silent> <Plug>MarkToggle :<C-u>call mark#Toggle()<CR>

nnoremap <silent> <Plug>MarkSearchCurrentNext :<C-u>call mark#SearchCurrentMark(0)<CR>
nnoremap <silent> <Plug>MarkSearchCurrentPrev :<C-u>call mark#SearchCurrentMark(1)<CR>
nnoremap <silent> <Plug>MarkSearchAnyNext     :<C-u>call mark#SearchAnyMark(0)<CR>
nnoremap <silent> <Plug>MarkSearchAnyPrev     :<C-u>call mark#SearchAnyMark(1)<CR>
nnoremap <silent> <Plug>MarkSearchNext        :<C-u>if !mark#SearchNext(0)<Bar>execute 'normal! *zv'<Bar>endif<CR>
nnoremap <silent> <Plug>MarkSearchPrev        :<C-u>if !mark#SearchNext(1)<Bar>execute 'normal! #zv'<Bar>endif<CR>
" When typed, [*#nN] open the fold at the search result, but inside a mapping or
" :normal this must be done explicitly via 'zv'. 


if !hasmapto('<Plug>MarkSet', 'n')
	nmap <unique> <silent> <Leader>m <Plug>MarkSet
endif
if !hasmapto('<Plug>MarkSet', 'v')
	vmap <unique> <silent> <Leader>m <Plug>MarkSet
endif
if !hasmapto('<Plug>MarkRegex', 'n')
	nmap <unique> <silent> <Leader>r <Plug>MarkRegex
endif
if !hasmapto('<Plug>MarkRegex', 'v')
	vmap <unique> <silent> <Leader>r <Plug>MarkRegex
endif
if !hasmapto('<Plug>MarkClear', 'n')
	nmap <unique> <silent> <Leader>n <Plug>MarkClear
endif
" No default mapping for <Plug>MarkAllClear. 
" No default mapping for <Plug>MarkToggle. 

if !hasmapto('<Plug>MarkSearchCurrentNext', 'n')
	nmap <unique> <silent> <Leader>* <Plug>MarkSearchCurrentNext
endif
if !hasmapto('<Plug>MarkSearchCurrentPrev', 'n')
	nmap <unique> <silent> <Leader># <Plug>MarkSearchCurrentPrev
endif
if !hasmapto('<Plug>MarkSearchAnyNext', 'n')
	nmap <unique> <silent> <Leader>/ <Plug>MarkSearchAnyNext
endif
if !hasmapto('<Plug>MarkSearchAnyPrev', 'n')
	nmap <unique> <silent> <Leader>? <Plug>MarkSearchAnyPrev
endif
if !hasmapto('<Plug>MarkSearchNext', 'n')
	nmap <unique> <silent> * <Plug>MarkSearchNext
endif
if !hasmapto('<Plug>MarkSearchPrev', 'n')
	nmap <unique> <silent> # <Plug>MarkSearchPrev
endif


"- commands -------------------------------------------------------------------
command! -nargs=? Mark call mark#DoMark(<f-args>)
command! -bar MarkClear call mark#ClearAll()

command! -bar MarkLoad call mark#LoadCommand(1)
command! -bar MarkSave call mark#SaveCommand()


"- marks persistence ----------------------------------------------------------
if g:mwAutoLoadMarks
	" As the viminfo is only processed after sourcing of the runtime files, the
	" persistent global variables are not yet available here. Defer this until Vim
	" startup has completed. 
	function! s:AutoLoadMarks()
		if g:mwAutoLoadMarks && exists('g:MARK_MARKS') && g:MARK_MARKS !=# '[]'
			if ! exists('g:MARK_ENABLED') || g:MARK_ENABLED
				" There are persistent marks and they haven't been disabled; we need to
				" show them right now. 
				call mark#LoadCommand(0)
			else
				" Though there are persistent marks, they have been disabled. We avoid
				" sourcing the autoload script and its invasive autocmds right now;
				" maybe the marks are never turned on. We just inform the autoload
				" script that it should do this once it is sourced on-demand by a
				" mark mapping or command. 
				let g:mwDoDeferredLoad = 1
			endif
		endif
	endfunction

	augroup MarkInitialization
		autocmd!
		" Note: Avoid triggering the autoload unless there actually are persistent
		" marks. For that, we need to check that g:MARK_MARKS doesn't contain the
		" empty list representation, and also :execute the :call. 
		autocmd VimEnter * call <SID>AutoLoadMarks()
	augroup END
endif

" vim: ts=2 sw=2
