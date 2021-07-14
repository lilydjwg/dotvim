" ingo/hlgroup.vim: Functions around highlight groups.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#hlgroup#LinksTo( name )
    return synIDattr(synIDtrans(hlID(a:name)), 'name')
endfunction

function! ingo#hlgroup#GetColor( isBackground, syntaxId, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Get the foreground / background color of a:syntaxId [in a:mode], considering
"   the effect of a set "reverse" attribute.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isBackground  Flag whether the background color should be returned.
"   a:syntaxId      Syntax ID, to be obtained via hlID().
"   a:mode          Optional UI color mode.
"* RETURN VALUES:
"   Color name / RGB color in GUI mode.
"******************************************************************************
    let l:mode = (a:0 ? a:1 : '')
    let l:attributes = ['fg', 'bg']
    if a:isBackground | call reverse(l:attributes) | endif
    if synIDattr(synIDtrans(a:syntaxId), 'reverse', l:mode) | call reverse(l:attributes) | endif

    return synIDattr(synIDtrans(a:syntaxId), l:attributes[0] . (l:mode ==# 'gui' ? '#' : ''), l:mode)    " Note: Use RGB comparison for GUI mode to account for the different ways of specifying the same color.
endfunction
function! ingo#hlgroup#GetForegroundColor( syntaxId, ... ) abort
    return call('ingo#hlgroup#GetColor', [0, a:syntaxId] + a:000)
endfunction
function! ingo#hlgroup#GetBackgroundColor( syntaxId, ... ) abort
    return call('ingo#hlgroup#GetColor', [1, a:syntaxId] + a:000)
endfunction

function! ingo#hlgroup#GetApplicableColorModes() abort
"******************************************************************************
"* PURPOSE:
"   Get UI color modes that are applicable to the current Vim session.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   List of mode(s) (gui, cterm) that apply to the current session.
"******************************************************************************
    if has('gui_running')
	" Can't get back from GUI to terminal.
	return ['gui']
    elseif has('gui') || has('nvim')
	" This terminal may be upgraded to the GUI via :gui.
	" Neovim uses cterm or gui depending on &termguicolors, and can be
	" changed whenever the user wishes to.
	return ['cterm', 'gui']
    else
	" This terminal doesn't have GUI capabilities built in.
	return ['cterm']
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
