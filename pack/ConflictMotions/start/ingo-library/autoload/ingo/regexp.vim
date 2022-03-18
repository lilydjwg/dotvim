" ingo/regexp.vim: Functions around handling regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2010-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#GetSpecialCharacters()
    " The set of characters that must be escaped depends on the 'magic' setting.
    return ['^$', '^$.*[~'][&magic]
endfunction
function! ingo#regexp#EscapeLiteralText( text, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape the literal a:text for use in search command.
"   The ignorant approach is to use atom \V, which sets the following pattern to
"   "very nomagic", i.e. only the backslash has special meaning. For \V, \ still
"   must be escaped. But that's not how the built-in star command works.
"   Instead, all special search characters must be escaped.
"
"   This works well even with <Tab> (no need to change ^I into \t), but not with
"   a line break, which must be changed from ^M to \n.
"
"   We also may need to escape additional characters like '/' or '?', because
"   that's done in a search via '*', '/' or '?', too. As the character depends
"   on the search direction ('/' vs. '?'), this is passed in as
"   a:additionalEscapeCharacters.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Literal text.
"   a:additionalEscapeCharacters    For use in the / command, add '/', for the
"				    backward search command ?, add '?'. For
"				    assignment to @/, always add '/', regardless
"				    of the search direction; this is how Vim
"				    escapes it, too. For use in search(), pass
"				    an empty String or omit the argument.
"* RETURN VALUES:
"   Regular expression for matching a:text.
"*******************************************************************************
    return substitute(escape(a:text, '\' . ingo#regexp#GetSpecialCharacters() . (a:0 ? a:1 : '')), "\n", '\\n', 'g')
endfunction
function! ingo#regexp#EscapeLiteralReplacement( text, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape the literal a:text for use as the replacement text in a :substitute
"   command (which needs additional escape characters (usually '/') and consider
"   'magic') / substitute() function.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Literal text.
"   a:additionalEscapeCharacters    For use with :substitute, pass the separator
"                                   character (e.g. '/').
"                                   For use in substitute(), omit the argument.
"* RETURN VALUES:
"   Replacement text for replacing a:text.
"*******************************************************************************
    return escape(a:text, '\' . (a:0 ? (&magic ? '&~' : '') . a:1 : '&'))
endfunction

function! ingo#regexp#MakeWholeWordSearch( text, ... )
"******************************************************************************
"* PURPOSE:
"   Generate a pattern that searches only for whole words of a:text, but only if
"   a:text actually starts / ends with keyword characters (so that non-word
"   a:text still matches (anywhere)).
"   The star command only creates a \<whole word\> search pattern if the <cword>
"   actually only consists of keyword characters. Since
"   ingo#regexp#FromLiteralText() could handle a superset (e.g. also
"   "foo...bar"), just ensure that the keyword boundaries can be enforced at
"   either side, to avoid enclosing a non-keyword side and making a match
"   impossible with it (e.g. "\<..bar\>").
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text / pattern to be searched for. Note that this isn't escaped in any form;
"	    you probably want to escape backslashes beforehand and use \V "very
"	    nomagic" on the result.
"   a:pattern   If passed, this is adapted according to what a:text is about.
"		Useful if the pattern has already been so warped (e.g. by
"		enclosing in /\(...\|...\)/) that word boundary detection on the
"		original text wouldn't work.
"* RETURN VALUES:
"   a:text / a:pattern, with additional \< / \> atoms if applicable.
"******************************************************************************
    let l:pattern = (a:0 ? a:1 : a:text)
    if a:text =~# '^\k'
	let l:pattern = '\<' . l:pattern
    endif
    if a:text =~# '\k$'
	let l:pattern .= '\>'
    endif
    return l:pattern
endfunction
function! ingo#regexp#MakeStartWordSearch( text, ... )
    let l:pattern = (a:0 ? a:1 : a:text)
    if a:text =~# '^\k'
	let l:pattern = '\<' . l:pattern
    endif
    return l:pattern
endfunction
function! ingo#regexp#MakeEndWordSearch( text, ... )
    let l:pattern = (a:0 ? a:1 : a:text)
    if a:text =~# '\k$'
	let l:pattern .= '\>'
    endif
    return l:pattern
endfunction
function! ingo#regexp#MakeWholeWORDSearch( text, ... )
"******************************************************************************
"* PURPOSE:
"   Generate a pattern that searches only for whole WORDs of a:text, but only if
"   a:text actually starts / ends with non-whitespace characters.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text / pattern to be searched for. Note that this isn't escaped in any form;
"	    you probably want to escape backslashes beforehand and use \V "very
"	    nomagic" on the result.
"   a:pattern   If passed, this is adapted according to what a:text is about.
"		Useful if the pattern has already been so warped (e.g. by
"		enclosing in /\(...\|...\)/) that word boundary detection on the
"		original text wouldn't work.
"* RETURN VALUES:
"   a:text / a:pattern, with additional atoms if applicable.
"******************************************************************************
    let l:pattern = (a:0 ? a:1 : a:text)
    if a:text =~# '^\S'
	let l:pattern = '\%(^\|\s\)\@<=' . l:pattern
    endif
    if a:text =~# '\S$'
	let l:pattern .= '\%(\s\|$\)\@='
    endif
    return l:pattern
endfunction
function! ingo#regexp#MakeWholeWordOrWORDSearch( text, ... )
"******************************************************************************
"* PURPOSE:
"   Generate a pattern that searches only for whole words or whole WORDs of
"   a:text, depending on whether a:text actually starts / ends with
"   keyword or non-whitespace (not necessarily the same type at begin and end)
"   characters.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text / pattern to be searched for. Note that this isn't escaped in any form;
"	    you probably want to escape backslashes beforehand and use \V "very
"	    nomagic" on the result.
"   a:pattern   If passed, this is adapted according to what a:text is about.
"		Useful if the pattern has already been so warped (e.g. by
"		enclosing in /\(...\|...\)/) that word boundary detection on the
"		original text wouldn't work.
"* RETURN VALUES:
"   a:text / a:pattern, with additional atoms if applicable.
"******************************************************************************
    let l:pattern = (a:0 ? a:1 : a:text)
    if a:text =~# '^\k'
	let l:pattern = '\<' . l:pattern
    elseif a:text =~# '^\S'
	let l:pattern = '\%(^\|\s\)\@<=' . l:pattern
    endif
    if a:text =~# '\k$'
	let l:pattern .= '\>'
    elseif a:text =~# '\S$'
	let l:pattern .= '\%(\s\|$\)\@='
    endif
    return l:pattern
endfunction

function! ingo#regexp#FromLiteralText( text, isWholeWordSearch, additionalEscapeCharacters )
"*******************************************************************************
"* PURPOSE:
"   Convert literal a:text into a regular expression, similar to what the
"   built-in * command does.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Literal text.
"   a:isWholeWordSearch	Flag whether only whole words (* command) or any
"			contained text (g* command) should match.
"			Note: If you do not need the a:isWholeWordSearch flag,
"			you can also use the ingo#regexp#EscapeLiteralText()
"			function.
"   a:additionalEscapeCharacters    For use in the / command, add '/', for the
"				    backward search command ?, add '?'. For
"				    assignment to @/, always add '/', regardless
"				    of the search direction; this is how Vim
"				    escapes it, too. For use in search(), pass
"				    nothing.
"* RETURN VALUES:
"   Regular expression for matching a:text.
"*******************************************************************************
    if a:isWholeWordSearch
	return ingo#regexp#MakeWholeWordSearch(a:text, ingo#regexp#EscapeLiteralText(a:text, a:additionalEscapeCharacters))
    else
	return ingo#regexp#EscapeLiteralText(a:text, a:additionalEscapeCharacters)
    endif
endfunction

function! ingo#regexp#FromWildcard( wildcardExpr, additionalEscapeCharacters )
"*******************************************************************************
"* PURPOSE:
"   Convert a shell-like a:wildcardExpr which may contain wildcards ? and * into
"   an (unanchored!) regular expression.
"
"   The ingo#regexp#fromwildcard#Convert() supports the full range of wildcards
"   and considers the path separators on different platforms. An anchored
"   version is ingo#regexp#fromwildcard#AnchoredToPathBoundaries().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:wildcardExpr  Text containing file wildcards.
"   a:additionalEscapeCharacters    For use in the / command, add '/', for the
"				    backward search command ?, add '?'. For
"				    assignment to @/, always add '/', regardless
"				    of the search direction; this is how Vim
"				    escapes it, too. For use in search(), pass
"				    nothing.
"* RETURN VALUES:
"   Regular expression for matching a:wildcardExpr.
"*******************************************************************************
    let l:expr = '\V' . escape(a:wildcardExpr, '\' . a:additionalEscapeCharacters)

    " From the wildcards; emulate ?, * and **, but not [xyz].
    let l:expr = substitute(l:expr, '?', '\\.', 'g')
    let l:expr = substitute(l:expr, '\*\*', '\\.\\*', 'g')
    let l:expr = substitute(l:expr, '\*', '\\[^/\\\\]\\*', 'g')
    return l:expr
endfunction

function! ingo#regexp#IsValid( expr, ... )
"******************************************************************************
"* PURPOSE:
"   Test whether a:expr is a valid regular expression.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   In case of an invalid regular expression, makes Vim's error accessible via
"   ingo#err#Get(...). Any desired custom a:context can be passed to this
"   function as the optional argument.
"* INPUTS:
"   a:expr  Regular expression to test for correctness.
"   a:context	Optional context for ingo#err#Get().
"* RETURN VALUES:
"   1 if Vim's regular expression parser accepts a:expr, 0 if an error is
"   raised.
"******************************************************************************
    try
	call match('', a:expr)
	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call call('ingo#err#SetVimException', a:000)
	return 0
    endtry
endfunction

function! ingo#regexp#Anchored( expr, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Anchor the passed a:expr to beginning and end (by wrapping with ^ and $).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Regular expression in normal magic format.
"   a:emptyExpr Return value if a:expr is empty; by default, matches an empty
"               String / line (^$).
"* RETURN VALUES:
"   Embellished a:expr.
"******************************************************************************
    return (empty(a:expr) ? (a:0 ? a:1 : '^$') : '^\%(' . a:expr . '\)$')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
