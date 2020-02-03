" ingo/escape/command.vim: Additional escapings of Ex commands.
"
" DEPENDENCIES:
"   - ingo/collections/fromsplit.vim autoload script
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.002	29-Apr-2016	Add ingo#escape#command#mapunescape().
"   1.012.001	09-Aug-2013	file creation

function! ingo#escape#command#mapescape( command )
"******************************************************************************
"* PURPOSE:
"   Escape the Ex command a:command for use in the right-hand side of a mapping.
"   If you want to redefine an existing mapping, use ingo#compat#maparg()
"   instead; it already returns this in the correct format.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:command   Ex command(s).
"* RETURN VALUES:
"   a:command for use in a :map command.
"******************************************************************************
    let l:command = a:command
    let l:command = substitute(l:command, '<', '<lt>', 'g')     " '<' may introduce a special-notation key; better escape them all.
    let l:command = substitute(l:command, '|', '<Bar>', 'g')    " '|' must be escaped, or the map command will end prematurely.
    return l:command
endfunction

function! ingo#escape#command#mapunescape( command )
"******************************************************************************
"* PURPOSE:
"   Unescape special mapping characters (<Bar>, <lt>) in a:command.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:command   Ex command(s).
"* RETURN VALUES:
"   a:command for use in a :map command.
"******************************************************************************
    let l:command = a:command
    let l:command = substitute(l:command, '<lt>', '<', 'g')
    let l:command = substitute(l:command, '<Bar>', '|', 'g')
    return l:command
endfunction

function! ingo#escape#command#mapeval( mapping )
"******************************************************************************
"* PURPOSE:
"   Interpret mapping characters (<C-W>, <CR>) into the actual characters (^W,
"   ^M).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:mapping   String that may contain 'key-notation'.
"* RETURN VALUES:
"   a:mapping with key notation mapping characters converted into the actual
"   characters.
"******************************************************************************
    " Split on <...> and prefix those with a backslash. The rest needs
    " backslashes and double quotes escaped (for string interpolation), the
    " <...> only (unlikely) double quotes; <C-\\> != <C-\>!
    let l:string = join(
    \   ingo#collections#fromsplit#MapItemsAndSeparators(a:mapping, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!<[^>]\+>',
    \       'escape(v:val, ''\"'')',
    \       '"\\" . escape(v:val, ''"'')'
    \   ),
    \   ''
    \)
    execute 'return "' . l:string . '"'
endfunctio

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
