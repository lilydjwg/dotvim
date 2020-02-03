" ingo/regexp/split.vim: Functions to split a regular expression.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/regexp/length.vim autoload script
"   - ingo/regexp/magic.vim autoload script
"
" Copyright: (C) 2017-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#split#TopLevelBranches( pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:pattern on "\|" - separated branches, keeping nested \(...\|...\)
"   branches inside (non-)capture groups together. If the complete a:pattern is
"   wrapped in a group, it is treated as one toplevel branch, too.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax (...|...). If you may have
"   this, convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   List of regular expression branch fragments.
"******************************************************************************
    let l:rawBranches = split(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\|', 1)
    let l:openGroupCnt = 0
    let l:branches = []

    let l:currentBranch = ''
    while ! empty(l:rawBranches)
	let l:currentBranch = remove(l:rawBranches, 0)
	let l:currentOpenGroupCnt = l:openGroupCnt

	let l:count = 1
	while 1
	    let l:match = matchstr(l:currentBranch, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(%\?(\|)\)', 0, l:count)
	    if empty(l:match)
		break
	    elseif l:match == '\)'
		let l:openGroupCnt = max([0, l:openGroupCnt - 1])
	    else
		let l:openGroupCnt += 1
	    endif
	    let l:count += 1
	endwhile

	if l:currentOpenGroupCnt == 0
	    call add(l:branches, l:currentBranch)
	else
	    if empty(l:branches)
		let l:branches = ['']
	    endif
	    let l:branches[-1] .= '\|' . l:currentBranch
	endif
    endwhile

    return l:branches
endfunction

function! ingo#regexp#split#PrefixGroupsSuffix( pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:pattern into a \(...\) group (capture or non-capture), and any
"   preceding / trailing regular expression parts.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax (...|...). If you may have
"   this, convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   List of [prefix, group1, [infix, group2, [...]] suffix], or [a:pattern] if
"   there's no toplevel group at all.
"   Throws 'PrefixGroupsSuffix: Unmatched \(' or
"   'PrefixGroupsSuffix: Unmatched \)' if a:pattern is invalid.
"******************************************************************************
    let l:pattern = a:pattern
    let l:result = []
    let l:accu = ''
    let l:openGroupCnt = 0
    while 1
	let l:parse = matchlist(l:pattern, '^\(.\{-}\)\(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(%\?(\|)\)\)\(.*\)$')
	if empty(l:parse)
	    " No more open / close parentheses.
	    call add(l:result, l:pattern)
	    break
	endif
	let [l:prefix, l:paren, l:pattern] = l:parse[1:3]

	let l:isOpen = (l:paren !=# '\)')
	let l:openGroupCnt += (l:isOpen ? 1 : -1)
	if l:openGroupCnt < 0
	    throw 'PrefixGroupsSuffix: Unmatched \)'
	elseif l:isOpen && l:openGroupCnt == 1
	    call add(l:result, l:prefix)
	elseif ! l:isOpen && l:openGroupCnt == 0
	    call add(l:result, l:accu . l:prefix)
	    let l:accu = ''
	else
	    let l:accu .= l:prefix . l:paren
	endif
    endwhile
    if l:openGroupCnt != 0
	throw 'PrefixGroupsSuffix: Unmatched \('
    endif

    return l:result
endfunction

function! ingo#regexp#split#AddPatternByProjectedMatchLength( branches, pattern )
"******************************************************************************
"* PURPOSE:
"   Add a:pattern to the List of regexp a:branches, in a position so that
"   shorter earlier branches do not eclipse a following longer match.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax, in neither a:branches nor
"   a:pattern. If you may have this, convert via ingo#regexp#magic#Normalize()
"   first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:branches  List of regular expression branches (e.g. split via
"               ingo#regexp#split#TopLevelBranches()).
"   a:pattern   Regular expression to be added at the appropriate position in
"               a:branches, depending on the projected length of the matches.
"               Longer matches will come first, so that a shorter earlier match
"               does not eclipse a following longer one.
"* RETURN VALUES:
"   Modified a:branches List.
"******************************************************************************
    try
	let l:projectedPatternMinLength = ingo#regexp#length#Project(a:pattern)[0]
    catch /^PrefixGroupsSuffix:/
	let l:projectedPatternMinLength = 0
    endtry

    let l:i = 0
    while l:i < len(a:branches)
	try
	    let [l:min, l:max] = ingo#regexp#length#Project(a:branches[l:i])
	    let l:compare = (l:max < 0x7FFFFFFF ? l:max : l:min)
	    if l:compare < l:projectedPatternMinLength
		break
	    endif
	catch /^PrefixGroupsSuffix:/
	    " Skip invalid existing branch.
	endtry

	let l:i += 1
    endwhile
    return insert(a:branches, a:pattern, l:i)
endfunction

function! ingo#regexp#split#GlobalFlags( pattern )
"******************************************************************************
"* PURPOSE:
"   Split global regular expression engine flags from a:pattern. These control
"   case sensitivity (/\c, /\C) and engine type (/\%#=0).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   [engineTypeFlag, caseSensitivityFlag, purePattern]
"******************************************************************************
    let [l:fragments, l:caseFlags] = ingo#collections#SeparateItemsAndSeparators(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[cC]')
    let [l:fragments, l:engineFlags] = ingo#collections#SeparateItemsAndSeparators(join(l:fragments, ''), '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%#=[012]')
    let l:purePattern = join(l:fragments, '')

    let l:caseSensitivityFlag = (index(l:caseFlags, '\c') == -1 ? get(l:caseFlags, 0, '') : '\c')
    return [get(l:engineFlags, 0, ''), l:caseSensitivityFlag, l:purePattern]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
