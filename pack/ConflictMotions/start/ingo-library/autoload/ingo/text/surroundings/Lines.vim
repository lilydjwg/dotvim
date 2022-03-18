" ingo/text/surroundings/Lines.vim: Generic functions to surround whole lines with something.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:Transform( startLnum, endLnum, Transformer )
    try
	let l:originalLineNum = line('$')
	if type(a:Transformer) == type(function('tr'))
	    " Note: When going through call(), the Funcref is invoked once
	    " for each line, even when the referenced function is defined
	    " with the "range" attribute! Therefore, the transformer needs
	    " to be invoked directly. (Fortunately, we have no arguments to
	    " pass.)
	    execute a:startLnum . ',' . a:endLnum . 'call ' . ingo#funcref#ToString(a:Transformer) . '()'
	else
	    execute a:startLnum . ',' . a:endLnum . a:Transformer
	endif

	let l:offset = line('$') - l:originalLineNum
	return [1, l:offset]
    catch /^Vim\%((\a\+)\)\=:E16:/ " E16: Invalid range
	call ingo#err#Set(printf('Invalid last modified range: %d,%d', a:startLnum, a:endLnum))
	return [0, 0]
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return [0, 0]
    catch
	call ingo#err#SetCustomException(v:exception)
	return [0, 0]
    endtry
endfunction
function! ingo#text#surroundings#Lines#SurroundCommand( beforeLines, afterLines, options, count, startLnum, endLnum, Command )
"******************************************************************************
"* PURPOSE:
"   Surround the lines between a:startLnum and a:endLnum with added
"   a:beforeLines and a:afterLines and/or transform them via a:Transformer.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the lines.
"* INPUTS:
"   a:beforeLines   List of text lines to be prepended before a:startLnum, or a
"		    Funcref returning such.
"   a:afterLines    List of text lines to be appended after a:endLnum, or a
"		    Funcref returning such.
"   a:options.TransformerBefore
"		    Hook to transform the range of lines before they have been
"		    surrounded.
"		    When not empty, is invoked as a Funcref / Ex command with
"		    the a:firstline, a:lastline range and no arguments. Should
"		    transform the range.
"   a:options.TransformerAfter
"		    Hook to transform the surrounded range of lines.
"   a:options.CommandParser
"		    Hook to extract the actual command from a:Command (which is
"		    passed to the Funcref, and additionally an empty
"		    surroundingsContext Dict, into which parsed OPTIONs can be
"		    put, and then retrieved by transformers via
"		    g:surroundingsContext). Useful to support
"		    :Command {OPTION} ... {cmd}.
"   a:count         Range as <count> to check for default. When no range is
"		    passed in a command defined with -range=-1, the last
"		    modified range '[,'] is used instead of the following two
"		    arguments.
"   a:startLnum     Begin of the range to be surrounded.
"   a:endLnum       End of the range to be surrounded.
"   a:Command       A Funcref is passed the a:startLnum, a:endLnum and is
"		    expected to return a likewise List, which is then used. A
"		    non-empty String is executed as an Ex command, and the
"		    modified range is used instead of a:startLnum, a:endLnum.
"* RETURN VALUES:
"   1 in case of success; 0 if an error occurred. Use ingo#err#Get() to obtain
"   (and :echoerr) the message.
"******************************************************************************
    let l:TransformerBefore = get(a:options, 'TransformerBefore', '')
    let l:TransformerAfter = get(a:options, 'TransformerAfter', '')
    let l:Command = a:Command
    let l:CommandParser = get(a:options, 'CommandParser', '')
    if ! empty(l:CommandParser)
	let g:surroundingsContext = {}
	let l:Command = call(l:CommandParser, [l:Command, g:surroundingsContext])
    endif

    if a:count == -1
	" When no [range] is passed, -range=-1 defaults to <count> == -1.
	let [l:startLnum, l:endLnum] = [line("'["), line("']")]
    else
	let [l:startLnum, l:endLnum] = [a:startLnum, a:endLnum]
    endif
    if ! empty(l:Command)
	try
	    if type(l:Command) == type(function('tr'))
		let [l:startLnum, l:endLnum] = call(l:Command, [l:startLnum, l:endLnum])
	    else
		execute l:Command
		let [l:startLnum, l:endLnum] = [line("'["), line("']")]
	    endif
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#err#SetVimException()
	    return 0
	catch
	    call ingo#err#Set(v:exception)
	    return 0
	endtry
    endif

    if ! empty(l:TransformerBefore)
	let [l:isSuccess, l:offset] = s:Transform(l:startLnum, l:endLnum, l:TransformerBefore)
	if l:isSuccess
	    let l:endLnum += l:offset
	else
	    return 0
	endif
    endif

    let l:beforeLines = []
    let l:afterLines = []
    if ! empty(a:afterLines)
	let l:afterLines = ingo#actions#ValueOrFunc(a:afterLines)
	silent call ingo#lines#PutWrapper(l:endLnum, 'put', l:afterLines)
    endif
    if ! empty(a:beforeLines)
	let l:beforeLines = ingo#actions#ValueOrFunc(a:beforeLines)
	silent call ingo#lines#PutWrapper(l:startLnum, 'put!', l:beforeLines)
    endif
    let l:endLnum += len(l:beforeLines) + len(l:afterLines)

    if ! empty(l:TransformerAfter)
	let [l:isSuccess, l:offset] = s:Transform(l:startLnum, l:endLnum, l:TransformerAfter)
	if l:isSuccess
	    let l:endLnum += l:offset
	else
	    return 0
	endif
    endif

    " The entire block is the last changed text, not just the start marker that
    " was added last.
    call ingo#change#Set([l:startLnum, 1], [l:endLnum, 1])

    unlet! g:surroundingsContext    " Sloppily clean this up only on the happy path, but it's really not that important.

    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
