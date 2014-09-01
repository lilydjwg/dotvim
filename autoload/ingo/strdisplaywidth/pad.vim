" ingo/strdisplaywidth/pad.vim: Functions for padding a string to certain display width.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/tabstop.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	20-Jun-2013	file creation

function! ingo#strdisplaywidth#pad#Width( text, width, ... )
    let l:existingWidth = call('ingo#compat#strdisplaywidth', [a:text] + a:000)
    return max([0, a:width - l:existingWidth])
endfunction
function! ingo#strdisplaywidth#pad#Left( text, width, ... )
    " Any contained <Tab> characters would change their width when the padding
    " is prepended. Therefore, render them first into spaces.
    let l:renderedText = call('ingo#tabstops#Render', [a:text] + a:000)
    return repeat(' ', ingo#strdisplaywidth#pad#Width(l:renderedText, a:width)) . l:renderedText
endfunction
function! ingo#strdisplaywidth#pad#Right( text, width, ... )
    return a:text . repeat(' ', call('ingo#strdisplaywidth#pad#Width', [a:text, a:width] + a:000))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
