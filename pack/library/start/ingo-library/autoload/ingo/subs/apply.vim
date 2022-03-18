" ingo/subs/apply.vim: Transform text through a passed expression that can take multiple forms.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#subs#apply#FlexibleExpression( text, textMode, expression ) abort
"******************************************************************************
"* PURPOSE:
"   Apply a:expression to a:text, which is in a:textMode.
"			The expression can be:
"			- a Vimscript expression; |v:val| will contain the
"			  text.
"			- a function name (without parentheses); the function
"			  will be passed the text as a single String argument.
"			- If the expression begins with '!', it will be
"			  treated as an external command, and passed to the
"			  |system()| function, with the text as stdin. (To use
"			  an expression beginning with logical not (|expr-!|),
"			  include a space before the '!' character.)
"			- If the expression begins with ':', the text will be
"			  placed in a scratch buffer (of the same 'filetype'),
"			  and the Ex command(s) will be applied.
"			- If the expression begins with /{pattern}/, each
"			  match (of the last search pattern if empty) inside
"			  the text is individually passed through the
"			  following expression / function name / external
"			  command / Ex command, then re-joined with the
"			  separating non-matches in between.
"			  When an expression returns a List, all elements are
"			  joined with the first occurring separator in the input
"			  text.
"			- If the expression begins with ^{pattern}^, the text
"			  is split on {pattern} (last search pattern if
"			  empty), and each item is individually passed through
"			  the following expression / function name / external
"			  command / Ex command, then re-joined with the
"			  separators in between.
"			  When an expression returns a List, all elements are
"			  joined with the first separator match of {pattern} in
"			  the input text.
"			- If the expression begins with ".", each individual
"			  line is passed through the following expression /
"			  function name / external command / Ex command.
"			  separators in between.
"			  To omit a line through an expression, return an empty
"			  List ([]). To expand a line into several, return a
"			  List of lines.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text          Input text.
"   a:textMode      "v" for characterwise, "V" for linewise.
"   a:expression    The expression; typically queried from the user.
"
"* RETURN VALUES:
"   Transformed a:text. Note: If a passed a:expression returns a List, this will
"   be joined appropriately if the expression is applied to matches, splits, or
"   lines. The List is returned as-is in case of a single expression (or
"   function) application, and it's up to the client to join this as desired.
"******************************************************************************
    if ingo#str#StartsWith(a:expression, '.')
	return join(ingo#collections#Flatten1(
	\   map(
	\       split(substitute(a:text, '\n$', '', ''), '\n', 1),
	\       printf('ingo#subs#apply#FlexibleExpression(v:val, "v", %s)', string(a:expression[1:]))
	\   )), "\n"
	\)
    endif

    let [l:separator, l:escapedPattern, l:rest] = ingo#str#split#MatchFirst(a:expression, '^\([/^]\)\zs.\{-}\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\ze\1')
    if ! empty(l:rest)
	if empty(l:escapedPattern)
	    if empty(@/)
		throw 'No previous search pattern'
	    endif
	    let l:pattern = @/
	else
	    let l:pattern = ingo#escape#Unescape(l:escapedPattern, l:separator)
	endif

	let l:isProcessMatches = (l:separator ==# '/')
	if l:isProcessMatches
	    let l:newElementJoiner = get(split(a:text, l:pattern), 0, '')
	else
	    let l:newElementJoiner = matchstr(a:text, l:pattern)
	endif

	return join(
	\   ingo#collections#fromsplit#MapOne(
	\       ! l:isProcessMatches, a:text, l:pattern,
	\       printf('ingo#subs#apply#Flatten(%s, ingo#subs#apply#FlexibleExpression(v:val, (ingo#str#EndsWith(v:val, "\n") ? "V" : "v"), %s))',
	\           string(l:newElementJoiner), string(l:rest[1:])
	\       )
	\   ), ''
	\)
    endif

    let l:expression = a:expression
    let l:isSystem = 0
    if l:expression =~? '^\%(g:\)\?[a-z][a-z0-9#_]\+$'
	let l:expression .= '(v:val)'
    elseif ingo#str#StartsWith(l:expression, '!')
	let l:expression = printf('%s(%s, v:val)', (a:textMode ==# 'V' ? 'system' : 'ingo#system#Chomped'), string(l:expression[1:]))
	let l:isSystem = 1
    elseif ingo#str#StartsWith(l:expression, ':')
	let l:originalFiletypeCommand = (empty(&l:filetype) || l:expression =~# '^:setf\s' ?
	\   '' :
	\   printf("execute 'silent! setf %s'|", &l:filetype)
	\)
	return ingo#buffer#temp#ExecuteWithText(a:text, l:originalFiletypeCommand . l:expression[1:])
    endif

    let l:result = ingo#actions#EvaluateWithVal(l:expression, a:text)

    if (l:isSystem || ingo#str#StartsWith(l:expression, 'system(')) && v:shell_error != 0
	throw ingo#msg#MsgFromShellError('execute', l:result)
    endif

    return l:result
endfunction
function! ingo#subs#apply#Flatten( joiner, result ) abort
    return (type(a:result) == type([]) ?
    \   join(a:result, a:joiner) :
    \   a:result
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
