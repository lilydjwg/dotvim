" ingo/range/Lines.vim: Functions for retrieving line numbers of ranges.
"
" DEPENDENCIES:
"   - ingo/cmdsargs/pattern.vim autoload script
"   - ingo/range.vim autoload script
"
" Copyright: (C) 2014-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:RecordLine( records, startLnum, endLnum )
    let l:lnum = line('.')
    if l:lnum < a:startLnum || l:lnum > a:endLnum
	let s:didRecord = 0
	return
    endif

    let a:records[l:lnum] = 1
    let s:didRecord = 1
endfunction
function! s:RecordLines( records, startLines, endLines, startLnum, endLnum ) range
    execute printf('%d,%dcall s:RecordLine(a:records, a:startLnum, a:endLnum)', a:firstline, a:lastline)
    if s:didRecord
	call add(a:startLines, max([a:firstline, a:startLnum]))
	call add(a:endLines, min([a:lastline, a:endLnum]))
    endif
endfunction
function! ingo#range#lines#Get( startLnum, endLnum, range, ... )
"******************************************************************************
"* PURPOSE:
"   Determine the line numbers and start and end lines of a:range that fall
"   inside a:startLnum and a:endLnum. Closed folds do not affect the recorded
"   lines; only the actually matched lines are considered.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the cursor position in the buffer (to the beginning of the last line
"   within the range).
"* INPUTS:
"   a:startLnum First line number to be considered.
"   a:endLnum   Last line number to be considered.
"   a:range     Range in any format supported by Vim, e.g. 'a,'b or
"		/^fun/,/^endfun/
"   a:options.isGetAllRanges    Flag whether (for pattern ranges like /.../),
"                               all (vs. only the next matching) ranges are
"                               determined. Defaults to 1; pass 0 to only get
"                               the next one.
"   a:options.isKeepPatterns    Flag whether a pattern range will not affect the
"                               search history (if :keeppatterns is supported);
"                               didClobberSearchHistory will then always be 0.
"                               Defaults to 1; pass 0 to have it added to the
"                               search history and affect @/ within the
"                               function.
"   a:isGetAllRanges    Deprecated: Optional flag whether (for pattern ranges
"                       like /.../), all (vs. only the next matching) ranges are
"                       determined.
"			Defaults to 1; pass 0 to only get the next one.
"* RETURN VALUES:
"   [recordedLnums, startLnums, endLnums, didClobberSearchHistory]
"   recordedLnums   Dictionary with all line numbers that fall into the range(s)
"		    as keys.
"   startLnums      List of line numbers where a range starts. Can contain
"		    multiple elements if a /pattern/ range is used.
"   endLnums        List of line numbers where a range ends.
"   didClobberSearchHistory Flag whether a command was used that has added a
"			    temporary pattern to the search history, and
"			    a:options.isKeepPatterns was not in effect. If true,
"			    call histdel('search', -1) at the end of the client
"			    function once.
"******************************************************************************
    let l:keeppatterns = matchstr(ingo#compat#commands#keeppatterns(), '^keeppatterns$')
    if a:0 && type(a:1) != type({})
	let l:isGetAllRanges = a:1
    else
	let l:options = (a:0 ? a:1 : {})
	let l:isGetAllRanges = get(l:options, 'isGetAllRanges', 1)
	if ! get(l:options, 'isKeepPatterns', 1)
	    let l:keeppatterns = ''
	endif
    endif
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    let l:recordedLines = {}
    let l:startLines = []
    let l:endLines = []
    let l:save_search = @/
    let l:didClobberSearchHistory = 0

    if l:isGetAllRanges && a:range =~# '[/?]'
	" For patterns, we need :global to find _all_ (not just the first)
	" matching ranges. For that, folds must be open / disabled. And because
	" of that, the actual ranges must be determined first.
	let l:save_foldenable = &l:foldenable
	setlocal nofoldenable

	let l:searchRange = a:range
	if ingo#cmdargs#pattern#RawParse(a:range, [''], '\s*[,;]\s*\S.*')[0] ==# '?'
	    " If this is a simple /{pattern}/, we can just match that with
	    " :global. But for actual ranges, these should extend both upwards
	    " (?foo?,/bar/) as well as downwards (/foo/,/bar/). To handle the
	    " former, we must make :global attempt a match at any line.
	    let l:searchRange = '/^/' . a:range
	endif

	try
	    execute printf('silent! %s %d,%dglobal %s call <SID>RecordLines(l:recordedLines, l:startLines, l:endLines, %d, %d)',
	    \   l:keeppatterns,
	    \   l:startLnum, l:endLnum,
	    \   l:searchRange,
	    \   l:startLnum, l:endLnum
	    \)
	finally
	    let &l:foldenable = l:save_foldenable
	endtry
    else
	" For line number, marks, etc., we can just record them (limited to
	" those that fall into the command's range).
	execute printf('silent! %s %s call <SID>RecordLines(l:recordedLines, l:startLines, l:endLines, %d, %d)',
	\   l:keeppatterns,
	\   a:range,
	\   l:startLnum, l:endLnum
	\)
    endif

    if empty(l:keeppatterns) && @/ !=# l:save_search
	let @/ = l:save_search
	let l:didClobberSearchHistory = 1
    endif

    return [l:recordedLines, l:startLines, l:endLines, l:didClobberSearchHistory]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
