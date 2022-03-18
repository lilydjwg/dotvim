" ingo/cmdargs/substitute.vim: Functions for parsing of :substitute arguments.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:ApplyEmptyFlags( emptyFlags, parsedFlags)
    return (empty(filter(copy(a:parsedFlags), '! empty(v:val)')) ? a:emptyFlags : a:parsedFlags)
endfunction
function! ingo#cmdargs#substitute#GetFlags( ... )
    return '&\?[cegiInp#lr' . (a:0 ? a:1 : '') . ']*'
endfunction

function! ingo#cmdargs#substitute#Parse( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse the arguments of a custom command that works like :substitute.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments The command's raw arguments; usually <q-args>.
"   a:options.flagsExpr             Pattern that captures any optional part
"				    after the replacement (usually some
"				    substitution flags). By default, captures
"				    the known :substitute |:s_flags| and
"				    optional [count]. Pass an empty string to
"				    disallow any flags.
"   a:options.additionalFlags       Flags that will be recognized in addition to
"				    the default |:s_flags|; default none. Modify
"				    this instead of passing a:options.flagsExpr
"				    if you want to recognize additional flags.
"   a:options.flagsMatchCount       Optional number of submatches captured by
"				    a:options.flagsExpr. Defaults to 2 with the
"				    default a:options.flagsExpr, to 1 with a
"				    non-standard non-empty a:options.flagsExpr,
"				    and 0 if a:options.flagsExpr is empty.
"   a:options.defaultReplacement    Replacement to use when the replacement part
"				    is omitted. Empty by default.
"   a:options.emptyPattern          Pattern to use when no arguments at all are
"				    given. Defaults to "", which automatically
"				    uses the last search pattern in a
"				    :substitute. You need to "/"-escape this
"				    yourself (to be able to pass in @/, which
"				    already is "/"-escaped (the default
"				    separator is "/")).
"   a:options.emptyReplacement      Replacement to use when no arguments at all
"				    are given. Defaults to "~" to use the
"				    previous replacement in a :substitute.
"   a:options.emptyFlags            Flags to use when a:options.flagsExpr is not
"				    empty, but no arguments at all are given.
"				    Defaults to ["&", ""] to use the previous
"				    flags of a :substitute. Provide a List if
"				    a:options.flagsMatchCount is larger than 1.
"   a:options.isAllowLoneFlags      Allow to omit /pat/repl/, and parse a
"				    stand-alone a:options.flagsExpr (assuming
"				    one is passed). On by default.
"* RETURN VALUES:
"   A list of [separator, pattern, replacement, flags, count] (default)
"   A list of [separator, pattern, replacement] when a:options.flagsExpr is
"   empty or a:options.flagsMatchCount is 0.
"   A list of [separator, pattern, replacement, submatch1, ...];
"   elements added depending on a:options.flagsMatchCount.
"   flags and count are meant to be directly concatenated; count therefore keeps
"   leading whitespace, but be aware that this is optional with :substitute,
"   too!
"   The replacement part is always escaped for use inside separator, also when
"   the default is taken.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:additionalFlags = get(l:options, 'additionalFlags', '')
    let l:flagsExpr = get(l:options, 'flagsExpr', '\(' . ingo#cmdargs#substitute#GetFlags(l:additionalFlags) . '\)\(\s*\d*\)')
    let l:isParseFlags = (! empty(l:flagsExpr))
    let l:flagsMatchCount = get(l:options, 'flagsMatchCount', (has_key(l:options, 'flagsExpr') ? (l:isParseFlags ? 1 : 0) : 2))
    let l:defaultFlags = (l:isParseFlags ? repeat([''], l:flagsMatchCount) : [])
    let l:defaultReplacement = get(l:options, 'defaultReplacement', '')
    let l:emptyPattern = get(l:options, 'emptyPattern', '')
    let l:emptyReplacement = get(l:options, 'emptyReplacement', '~')
    let l:emptyFlags = get(l:options, 'emptyFlags', ['&'] + repeat([''], l:flagsMatchCount - 1))
    let l:isAllowLoneFlags = get(l:options, 'isAllowLoneFlags', 1)

    let l:matches = matchlist(a:arguments, '\C^\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1' . l:flagsExpr . '$')
    if ! empty(l:matches)
	" Full /pat/repl/[flags].
	return l:matches[1:3] + (l:isParseFlags ? l:matches[4:(4 + l:flagsMatchCount - 1)] : [])
    endif

    let l:matches = matchlist(a:arguments, '\C^\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1\(.\{-}\)$')
    if ! empty(l:matches)
	" Partial /pat/[repl].
	return l:matches[1:2] + [(empty(l:matches[3]) ? escape(l:defaultReplacement, l:matches[1]) : l:matches[3])] + l:defaultFlags
    endif

    let l:matches = matchlist(a:arguments, '\C^\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)$')
    if ! empty(l:matches)
	" Minimal /[pat].
	return l:matches[1:2] + [escape(l:defaultReplacement, l:matches[1])] + l:defaultFlags
    endif

    if ! empty(a:arguments)
	if l:isParseFlags && l:isAllowLoneFlags
	    let l:matches = matchlist(a:arguments, '\C^' . l:flagsExpr . '$')
	    if ! empty(l:matches)
		" Special case of {flags} without /pat/string/.
		return ['/', l:emptyPattern, escape(l:emptyReplacement, '/')] + s:ApplyEmptyFlags(ingo#list#Make(l:emptyFlags), l:matches[1:(l:flagsMatchCount)])
	    endif
	endif

	" Literal pat.
	if ! empty(l:defaultReplacement)
	    " Clients cannot concatentate the results without a separator, so
	    " use one.
	    return ['/', escape(a:arguments, '/'), escape(l:defaultReplacement, '/')] + l:defaultFlags
	else
	    return ['', a:arguments, l:defaultReplacement] + l:defaultFlags
	endif
    else
	" Nothing.
	return ['/', l:emptyPattern, escape(l:emptyReplacement, '/')] + (l:isParseFlags ? ingo#list#Make(l:emptyFlags) : [])
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
