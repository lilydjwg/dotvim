" ingo/comments.vim: Functions around comment handling.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.005	06-Sep-2013	CHG: Make a:isIgnoreIndent flag to
"				ingo#comments#CheckComment() optional and add
"				a:isStripNonEssentialWhiteSpaceFromCommentString,
"				which is also on by default for DWIM.
"				CHG: Don't strip whitespace in
"				ingo#comments#RemoveCommentPrefix(); with the
"				changed ingo#comments#CheckComment() default
"				behavior, this isn't necessary, and is
"				unexpected.
"				ingo#comments#RenderComment: When the text
"				starts with indent identical to what
"				'commentstring' would render, avoid having
"				duplicate indent.
"   1.005.004	02-May-2013	Move to ingo-library.
"	003	24-May-2012	Add ingocomments#RemoveCommentPrefix().
"	002	09-Nov-2011	Add ingocomments#CheckComment() and
"				ingocomments#RenderComment(), used by
"				s:ReplaceWithEllided() in
"				plugin/ingosubstitutions2.vim.
"	001	22-Sep-2011	file creation

function! s:CommentDefinitions()
    return map(split(&l:comments, ','), 'matchlist(v:val, ''\([^:]*\):\(.*\)'')[1:2]')
endfunction

function! s:IsPrefixMatch( string, prefix )
    return strpart(a:string, 0, len(a:prefix)) ==# a:prefix
endfunction

function! ingo#comments#CheckComment( text, ... )
"******************************************************************************
"* PURPOSE:
"   Check whether a:text is a comment according to 'comments' definitions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text	The text to be checked. If the "b" flag is contained in
"		'comments', the proper whitespace must exist.
"   a:options.isIgnoreIndent	Flag; if set (the default), there must either be
"				no leading whitespace or exactly the amount
"				mandated by the indent of a three-piece comment.
"   a:options.isStripNonEssentialWhiteSpaceFromCommentString
"				Flag; if set (the default), any trailing
"				whitespace in the returned commentstring (e.g.
"				often indent in the middle part of a
"				three-piece) is stripped.
"* RETURN VALUES:
"   [] if a:text is not a comment.
"   [commentstring, type, nestingLevel, isBlankRequired] if a:text is a comment.
"	commentstring is the found comment prefix; if an offset was defined,
"	this is included.
"	type is empty for a normal comment leader, and either "s", "m" or "e"
"	for a three-piece comment.
"	nestingLevel is > 0 if the "n" flag is contained in 'comments' and
"	indicates the number of nested comments. Only repetitive same comments
"	are counted for nesting.
"	isBlankRequired is a boolean flag
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isIgnoreIndent = get(l:options, 'isIgnoreIndent', 1)
    let l:isStripNonEssentialWhiteSpaceFromCommentString = get(l:options, 'isStripNonEssentialWhiteSpaceFromCommentString', 1)

    let l:text = (l:isIgnoreIndent ? substitute(a:text, '^\s*', '', '') : a:text)

    for [l:flags, l:string] in s:CommentDefinitions()
	if l:flags =~# '[se]'
	    if l:flags =~# '[se].*\d' && l:flags !~# '-\d'
		if l:isIgnoreIndent
		    let l:threePieceOffset = ''
		else
		    " Consider positive offset for the middle of a three-piece
		    " comment when matching with a:text.
		    let l:threePieceOffset = repeat(' ', matchstr(l:flags, '\d\+'))
		endif
	    elseif l:flags =~# 's'
		" Clear any offset from previous three-piece comment.
		let l:threePieceOffset = ''
	    endif
	endif
	" TODO: Handle "r" right-align flag through offset, too.

	let l:commentstring = ''
	if s:IsPrefixMatch(l:text, l:string)
	    let l:commentstring = l:string
	elseif (l:flags =~# '[me]' && ! empty(l:threePieceOffset) && s:IsPrefixMatch(l:text, l:threePieceOffset . l:string))
	    let l:commentstring = l:threePieceOffset . l:string
	endif
	if ! empty(l:commentstring)
	    let l:isBlankRequired = (l:flags =~# 'b')
	    if l:isBlankRequired && l:text[stridx(l:text, l:string) + len(l:string)] !~# '\s'
		" The whitespace after the comment is missing.
		continue
	    endif

	    let l:nestingLevel = 0
	    if l:flags =~# 'n'
		let l:comments = matchstr(l:text, '\V\C\^\s\*\zs\%(' . escape(l:string, '\') . '\s' . (l:isBlankRequired ? '\+' : '\*') . '\)\+')
		let l:nestingLevel = strlen(substitute(l:comments, '\V\C' . escape(l:string, '\') . '\s\*', 'x', 'g'))
	    endif

	    if l:isStripNonEssentialWhiteSpaceFromCommentString
		let l:commentstring = substitute(l:commentstring, '\s*$', '', '')
	    endif
	    return [l:commentstring, matchstr(l:flags, '\C[sme]'), l:nestingLevel, l:isBlankRequired]
	endif
    endfor

    return []
endfunction

function! s:AvoidDuplicateIndent( commentstring, text )
    " When the text starts with indent identical to what 'commentstring' would
    " render, avoid having duplicate indent.
    let l:renderedIndent = matchstr(a:commentstring, '\s\+\ze%s')
    return (a:text =~# '^\V' . l:renderedIndent ? strpart(a:text, len(l:renderedIndent)) : a:text)
endfunction
function! ingo#comments#RenderComment( text, checkComment )
"******************************************************************************
"* PURPOSE:
"   Render a:text as a comment.
"* ASSUMPTIONS / PRECONDITIONS:
"   Uses comment format from 'commentstring', if defined.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  The text to be rendered.
"   a:checkComment  Comment information returned by ingo#comments#CheckComment().
"* RETURN VALUES:
"   Returns a:text unchanged if a:checkComment is empty.
"   Otherwise, returns a:text rendered as a comment (as good as it can).
"******************************************************************************
    if empty(a:checkComment)
	return a:text
    endif

    let [l:commentprefix, l:type, l:nestingLevel, l:isBlankRequired] = a:checkComment

    if &commentstring =~# '\V\C' . escape(l:commentprefix, '\') . (l:isBlankRequired ? '\s' : '')
	" The found comment is the same as 'commentstring' will generate.
	" Generate with the proper nesting.
	let l:render = s:AvoidDuplicateIndent(&commentstring, a:text)
	for l:ii in range(max([1, l:nestingLevel]))
	    let l:render = printf(&commentstring, l:render)
	endfor
	return l:render
    elseif ! empty(&commentstring)
	" No match, just use 'commentstring'.
	return printf(&commentstring, s:AvoidDuplicateIndent(&commentstring, a:text))
    else
	" No 'commentstring' defined, use same comment prefix.
	return repeat(l:commentprefix . (l:isBlankRequired ? ' ' : ''), max([1, l:nestingLevel])) . (l:isBlankRequired ? '' : ' ') . s:AvoidDuplicateIndent(' %s', a:text)
    endif
endfunction

function! ingo#comments#RemoveCommentPrefix( text, checkComment )
"******************************************************************************
"* PURPOSE:
"   Remove the detected a:checkComment from a:text. Whitespace between the
"   comment prefix and actual comment (that does not belong to the commentstring
"   itself) is kept.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  The text to be rendered comment-less.
"   a:checkComment  Comment information returned by ingo#comments#CheckComment().
"* RETURN VALUES:
"   Returns a:text unchanged if a:checkComment is empty.
"   Otherwise, returns a:text rendered without the comment prefix.
"******************************************************************************
    if empty(a:checkComment)
	return a:text
    endif

    let [l:commentprefix, l:type, l:nestingLevel, l:isBlankRequired] = a:checkComment

    return substitute(a:text, '\s*\V\C' . escape(l:commentprefix, '\') . (l:isBlankRequired ? '\s\@=' : ''), '', 'g')
endfunction

function! ingo#comments#GetCommentPrefixType( prefix )
"******************************************************************************
"* PURPOSE:
"   Check whether a:prefix is a comment leader as defined in 'comments'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:prefix	Text to be checked for being a comment prefix. There must either
"		be no leading whitespace or exactly the amount mandated by the
"		indent of a three-piece comment. No blank is required in
"		a:prefix, even if the "b" flag is contained in 'comments', so
"		this function can be used for checking as-you-type.
"* RETURN VALUES:
"   [] if a:prefix is not a comment leader.
"   [type, isBlankRequired] if a:prefix is a comment leader.
"	type is empty for a normal comment leader, and either "s", "m" or "e"
"	for a three-piece comment.
"	isBlankRequired is a boolean flag
"******************************************************************************
    for [l:flags, l:string] in s:CommentDefinitions()
	if l:flags =~# '[se]'
	    if l:flags =~# '[se].*\d' && l:flags !~# '-\d'
		" Consider positive offset for the middle of a three-piece
		" comment when matching with a:prefix.
		let l:threePieceOffset = repeat(' ', matchstr(l:flags, '\d\+'))
	    elseif l:flags =~# 's'
		" Clear any offset from previous three-piece comment.
		let l:threePieceOffset = ''
	    endif
	endif
	" TODO: Handle "r" right-align flag through offset, too.

	if a:prefix ==# l:string || (l:flags =~# '[me]' && a:prefix ==# (l:threePieceOffset . l:string))
	    return [matchstr(l:flags, '\C[sme]'), (l:flags =~# 'b')]
	endif
    endfor

    return []
endfunction

function! ingo#comments#GetThreePieceIndent( prefix )
"******************************************************************************
"* PURPOSE:
"   Check whether a:prefix is a comment leader of a three-piece comment as
"   defined in 'comments', and return the indent in case of a middle or end
"   comment prefix.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:prefix	Text that may be a comment prefix. Must not include leading or
"		trailing whitespace, only the actual comment characters.
"* RETURN VALUES:
"   Indent, or 0.
"******************************************************************************
    let l:threePieceOffset = 0
    for [l:flags, l:string] in s:CommentDefinitions()
	if l:flags =~# '[se]'
	    if l:flags =~# '[se].*\d' && l:flags !~# '-\d'
		" Extract positive offset for the middle or end of a three-piece
		" comment.
		let l:threePieceOffset = matchstr(l:flags, '\d\+')
	    elseif l:flags =~# 's'
		" Clear any offset from previous three-piece comment.
		let l:threePieceOffset = 0
	    endif
	endif
	if l:flags =~# '[me]' && a:prefix ==# l:string
	    return l:threePieceOffset
	endif
    endfor

    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
