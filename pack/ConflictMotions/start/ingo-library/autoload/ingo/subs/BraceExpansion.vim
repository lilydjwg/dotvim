" ingo/subs/BraceExpansion.vim: Generate arbitrary strings like in Bash.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/collections/fromsplit.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:MakeToken( symbol, level )
    return "\001" . a:level . a:symbol . "\001"
endfunction
function! s:ProcessListInBraces( bracesText, iterationCnt )
    let l:text = a:bracesText
    let l:text = substitute(l:text, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!,', s:MakeToken(a:iterationCnt, ';'), 'g')
    if l:text ==# a:bracesText
	let l:text = substitute(l:text, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\.\.', s:MakeToken(a:iterationCnt, '#'), 'g')
    endif
    return ingo#escape#Unescape(l:text, ',')
endfunction
function! s:ProcessBraces( text )
    " We need to process nested braces from the outside to the inside;
    " unfortunately, with regexp parsing, we cannot skip over inner matching
    " braces. To work around that, we process all braces from the inside out,
    " and translate them into special tokens: ^AN<^A ... ^AN;^A ... ^AN>^A,
    " where ^A is 0x01 (hopefully not occurring as this token in the text), N is
    " the nesting level (1 = innermost), and < ; > / < # > are the substitutes
    " for { , } / { .. }.
    let l:text = a:text
    let l:previousText = 'X' . a:text   " Make this unequal to the current one, handle empty string.

    let l:iterationCnt = 1
    while l:previousText !=# l:text
	let l:previousText = l:text
	let l:text = substitute(
	\   l:text,
	\   '\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!{\(\%([^{}]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[{}]\)*\%(,\|\.\.\)\%([^{}]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[{}]\)*\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!}',
	\   '\=submatch(1) . s:MakeToken(l:iterationCnt, "<") . s:ProcessListInBraces(submatch(2), l:iterationCnt) . s:MakeToken(l:iterationCnt, ">")',
	\   'g'
	\)
	let l:iterationCnt += 1
    endwhile

    return [l:iterationCnt - 2, l:text]
endfunction
function! s:ExpandOneLevel( TailCall, text, level )
    let l:parse = matchlist(a:text, printf('^\(.\{-}\)%s\(.\{-}\)%s\(.*\)$', s:MakeToken(a:level, '<'), s:MakeToken(a:level, '>')))
    if empty(l:parse)
	return (a:level > 1 ?
	\   s:ExpandOneLevel(a:TailCall, a:text, a:level - 1) :
	\   [a:text]
	\)
    endif

    let [l:pre, l:braceList, l:post] = l:parse[1:3]
    if l:braceList =~# s:MakeToken(a:level, '#')
	" Sequence.
	let l:sequenceElements = split(l:braceList, s:MakeToken(a:level, '#'), 1)
	let l:nonEmptySequenceElementNum = len(filter(copy(l:sequenceElements), '! empty(v:val)'))
	if l:nonEmptySequenceElementNum < 2 || l:nonEmptySequenceElementNum > 3
	    " Undo the brace translation.
	    return [substitute(a:text, s:MakeToken('\d\+', '\([#<>]\)'), '\={"#": "..", "<": "{", ">": "}"}[submatch(1)]', 'g')]
	endif
	let l:isNumericSequence = (len(filter(copy(l:sequenceElements), 'v:val !~# "^[+-]\\?\\d\\+$"')) == 0)
	if l:isNumericSequence
	    let l:numberElements = map(copy(l:sequenceElements), 'str2nr(v:val)')
	    let l:step = ingo#compat#abs(get(l:numberElements, 2, 1))
	    if l:step == 0 | let l:step = 1 | endif
	    let l:isZeroPadding = (l:sequenceElements[0] =~# '^0\d' || l:sequenceElements[1] =~# '^0\d')
	    if l:numberElements[0] > l:numberElements[1]
		let l:step = l:step * -1
	    endif
	    let l:braceElements = range(l:numberElements[0], l:numberElements[1], l:step)

	    if l:isZeroPadding
		let l:digitNum = max(map(l:sequenceElements[0:1], 'len(v:val)'))
		call map(l:braceElements, 'printf("%0" . l:digitNum . "d", v:val)')
	    endif
	else
	    let l:step = ingo#compat#abs(str2nr(get(l:sequenceElements, 2, 1)))
	    if l:step == 0 | let l:step = 1 | endif
	    let [l:nrParameter0, l:nrParameter1] = [char2nr(l:sequenceElements[0]), char2nr(l:sequenceElements[1])]
	    if l:nrParameter0 > l:nrParameter1
		let l:step = l:step * -1
	    endif
	    let l:braceElements = map(range(l:nrParameter0, l:nrParameter1, l:step), 'nr2char(v:val)')
	endif
    else
	" List (possibly nested).
	let l:braceElements = split(l:braceList, s:MakeToken(a:level, ';'), 1)

	if a:level > 1
	    let l:braceElements = ingo#collections#Flatten1(map(l:braceElements, 's:ExpandOneLevel("s:FlattenRecurse", v:val, a:level - 1)'))
	endif
    endif

    return call(a:TailCall, [a:TailCall, l:pre, l:braceElements, l:post, a:level])
endfunction
function! s:UnescapeExpansions( expansions )
    return map(a:expansions, 'ingo#escape#Unescape(v:val, "\\{}")')
endfunction
function! s:FlattenRecurse( TailCall, pre, braceElements, post, level )
    return ingo#collections#Flatten1(map(a:braceElements, 's:ExpandOneLevel(a:TailCall, a:pre . v:val . a:post, a:level)'))
endfunction
function! ingo#subs#BraceExpansion#ExpandStrict( expression )
    let [l:nestingLevel, l:processedText] = s:ProcessBraces(a:expression)
    let l:expansions = s:ExpandOneLevel(function('s:FlattenRecurse'), l:processedText, l:nestingLevel)
    return s:UnescapeExpansions(l:expansions)
endfunction

function! s:Collect( TailCall, pre, braceElements, post, level )
    return [a:pre, a:braceElements] + s:ExpandOneLevel(a:TailCall, a:post, a:level)
endfunction
function! ingo#subs#BraceExpansion#ExpandMinimal( expression )
    let [l:nestingLevel, l:processedText] = s:ProcessBraces(a:expression)
    let l:collections = s:ExpandOneLevel(function('s:Collect'), l:processedText, l:nestingLevel)
    let l:expansions = s:CollectionsToExpansions(l:collections)
    return s:UnescapeExpansions(l:expansions)
endfunction
function! s:CalculateExpansionNumber( cardinalities )
    let l:num = 1
    while ! empty(a:cardinalities)
	let l:num = l:num * remove(a:cardinalities, 0)
    endwhile
    return l:num
endfunction
function! s:Multiply( elements, cardinalityNum )
    return repeat(a:elements, a:cardinalityNum / len(a:elements))
endfunction
function! s:CollectionsToExpansions( collections )
    let l:cardinalities = ingo#compat#uniq(sort(
    \   map(
    \       filter(copy(a:collections), 'type(v:val) == type([])'),
    \       'len(v:val)'
    \   )))

    let l:expansionNum = s:CalculateExpansionNumber(l:cardinalities)
    call map(a:collections, 's:Multiply(ingo#list#Make(v:val), l:expansionNum)')

    let l:expansions = repeat([''], l:expansionNum)
    while len(a:collections) > 0
	let l:collection = remove(a:collections, 0)
	for l:i in range(l:expansionNum)
	    let l:expansions[l:i] .= l:collection[l:i]
	endfor
    endwhile
    return l:expansions
endfunction

function! s:ConvertOptionalElementInSquareBraces( expression )
    return substitute(a:expression, '\[\([^\]]\+\)\]', '{\1,}', 'g')
endfunction
function! ingo#subs#BraceExpansion#ExpandToList( expression, options )
"******************************************************************************
"* PURPOSE:
"   Expand a brace expression into a List of expansions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expression  One brace expression with {...} braces.
"   a:options.strict    Flag whether this works like Bash's Brace Expansion,
"			where each {...} multiplies the number of resulting
"			expansions. Defaults to true. If false, {...} with the
"			same number of alternatives are all grouped together,
"			resulting in fewer expansions:
"			    {foo,bar}To{Me,You} ~
"			    true:  fooToMe fooToYou barToMe barToYou
"			    false: fooToMe barToYou
"   a:options.optionalElementInSquareBraces
"		Flag whether to also handle a single optional element denoted as
"		[elem] instead of {elem,}.
"* RETURN VALUES:
"   All expanded values of the brace expression as a List of Strings.
"******************************************************************************
    return call(
    \   function(get(a:options, 'strict', 1) ?
    \       'ingo#subs#BraceExpansion#ExpandStrict' :
    \       'ingo#subs#BraceExpansion#ExpandMinimal'
    \   ),
    \   [get(a:options, 'optionalElementInSquareBraces', 0) ?
    \       s:ConvertOptionalElementInSquareBraces(a:expression) :
    \       a:expression
    \   ]
    \)
endfunction
function! ingo#subs#BraceExpansion#ExpandToString( expression, joiner, options )
"******************************************************************************
"* PURPOSE:
"   Expand a brace expression and join the expansions with a:joiner.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expression  One brace expression with {...} braces.
"   a:joiner    Literal text to be used to join the expanded expressions;
"		defaults to a <Space> character.
"   a:options               Additional options; see
"			    ingo#subs#BraceExpansion#ExpandToList().
"* RETURN VALUES:
"   All expanded values of the brace expression, joined by a:joiner, in a single
"   string.
"******************************************************************************
    return join(ingo#subs#BraceExpansion#ExpandToList(a:expression, a:options), a:joiner)
endfunction

function! ingo#subs#BraceExpansion#InsideText( text, ... )
"******************************************************************************
"* PURPOSE:
"   Expand "foo{x,y}" inside a:text to "foox fooy", like Bash's Brace Expansion.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Source text with braces.
"   a:joiner    Literal text to be used to join the expanded expressions;
"		defaults to a <Space> character.
"   a:braceSeparatorPattern Regular expression to separate the expressions where
"			    braces are expanded; defaults to a:joiner or
"			    any whitespace (also when empty string is passed).
"   a:options               Additional options; see
"			    ingo#subs#BraceExpansion#ExpandToList().
"* RETURN VALUES:
"   a:text, separated by a:braceSeparatorPattern, each part had brace
"   expressions expanded, then joined by a:joiner, and all put together again.
"******************************************************************************
    let l:joiner = (a:0 ? a:1 : ' ')
    let l:braceSeparatorPattern = (a:0 >= 2 && ! empty(a:2) ? a:2 : (a:0 ? '\V' . escape(l:joiner, '\') : '\_s\+'))
    let l:options = (a:0 >= 3 ? a:3 : {})

    let l:result = ingo#collections#fromsplit#MapItems(
    \   a:text,
    \   '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . l:braceSeparatorPattern,
    \   printf('ingo#subs#BraceExpansion#ExpandToString(ingo#escape#UnescapeExpr(v:val, %s), %s, %s)',
    \       string(l:braceSeparatorPattern), string(l:joiner), string(l:options)
    \   )
    \)

    return join(l:result, '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
