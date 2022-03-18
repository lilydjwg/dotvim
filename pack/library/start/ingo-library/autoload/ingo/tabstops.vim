" ingo/tabstops.vim: Functions to render and deal with the dynamic width of <Tab> characters.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.008	27-Jun-2013	FIX: ingo#tabstops#RenderMultiLine() doesn't
"				pass an optional second a:startColumn argument.
"				Rewrite the forwarding.
"   1.009.007	26-Jun-2013	Add ingo#tabstops#RenderMultiLine(), as
"				ingo#tabstops#Render() does not properly render
"				multi-line text.
"   1.008.006	07-Jun-2013	Fix the rendering for text containing
"				unprintable ASCII and double-width (east Asian)
"				characters. The assumption index == char width
"				doesn't work there; so determine the actual
"				screen width via strdisplaywidth().
"   1.008.005	07-Jun-2013	Move into ingo-library.
"	004	05-Jun-2013	In EchoWithoutScrolling#RenderTabs(), make
"				a:tabstop and a:startColumn optional.
"	003	15-May-2009	Added utility function
"				EchoWithoutScrolling#TranslateLineBreaks() to
"				help clients who want to echo a single line, but
"				have text that potentially contains line breaks.
"	002	16-Aug-2008	Split off TruncateTo() from Truncate().
"	001	22-Jul-2008	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#tabstops#DisplayWidth( column, tabstop )
    return a:tabstop - (a:column - 1) % a:tabstop
endfunction
function! ingo#tabstops#Render( text, ... )
"*******************************************************************************
"* PURPOSE:
"   Replaces <Tab> characters in a:text with the correct amount of <Space>,
"   depending on the a:tabstop value. a:startColumn specifies at which start
"   column a:text will be printed.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	    Text to be rendered. If the text contains newline
"		    characters, the rendering will be wrong in subsequent lines.
"		    Use ingo#tabstops#RenderMultiLine() then.
"   a:tabstop	    tabstop value (The built-in :echo command always uses a
"		    fixed value of 8; it isn't affected by the 'tabstop'
"		    setting.) Defaults to the buffer's 'tabstop' value.
"   a:startColumn   Column at which the text is to be rendered (default 1).
"* RETURN VALUES:
"   a:text with replaced <Tab> characters.
"*******************************************************************************
    if a:text !~# "\t"
	return a:text
    endif

    let l:tabstop = (a:0 ? a:1 : &l:tabstop)
    let l:startColumn = (a:0 > 1 ? a:2 : 1)
    let l:pos = 0
    let l:width = l:startColumn - 1
    let l:text = a:text
    while l:pos < strlen(l:text)
	let l:newPos = stridx(l:text, "\t", l:pos)
	if l:newPos == -1
	    break
	endif
	let l:newPart = strpart(l:text, l:pos, l:newPos - l:pos)
	let l:newWidth = ingo#compat#strdisplaywidth(l:newPart) " Note: strdisplaywidth() takes into account the current 'tabstop' value, but since we're never passing a <Tab> character into it, this doesn't matter here.
	let l:tabWidth = ingo#tabstops#DisplayWidth(1 + l:width + l:newWidth, l:tabstop)    " Here we're considering the current buffer's / passed 'tabstop' value.
	let l:text = strpart(l:text, 0, l:newPos) . repeat(' ', l:tabWidth) . strpart(l:text, l:newPos + 1)
"****D echomsg '****' l:pos l:width string(strtrans(l:newPart)) l:newWidth l:tabWidth
"****D echomsg '####' string(strtrans(l:text))
	let l:pos = l:newPos + l:tabWidth
	let l:width += l:newWidth + l:tabWidth
    endwhile

    return l:text
endfunction
function! ingo#tabstops#RenderMultiLine( text, ... )
"*******************************************************************************
"* PURPOSE:
"   Replaces <Tab> characters (in potentially multiple lines in) a:text with the
"   correct amount of <Space>, depending on the a:tabstop value. a:startColumn
"   specifies at which start column (each line of) a:text will be printed.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	    Text to be rendered. Each line (i.e. substring delimited by
"		    newline characters) will be rendered separately and
"		    therefore correctly.
"   a:tabstop	    tabstop value (The built-in :echo command always uses a
"		    fixed value of 8; it isn't affected by the 'tabstop'
"		    setting.) Defaults to the buffer's 'tabstop' value.
"   a:startColumn   Column at which the text is to be rendered (default 1).
"* RETURN VALUES:
"   a:text with replaced <Tab> characters.
"*******************************************************************************
    return
    \   join(
    \       map(
    \           split(a:text, '\n', 1),
    \           'call("ingo#tabstops#Render", [v:val] + a:000)'
    \       ),
    \       "\n"
    \   )
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
