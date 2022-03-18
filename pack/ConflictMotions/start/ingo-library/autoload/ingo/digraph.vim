" ingo/digraph.vim: Functions around digraphs.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Source: http://stackoverflow.com/a/18726519/813602
" Source: unicode#Digraph(char) in https://github.com/chrisbra/unicode.vim/blob/eddd9791c226a211fc3e433d5ecccb836364dd86/autoload/unicode.vim#L85
function! ingo#digraph#Get( char, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Obtain the digraph expansion of a:char.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:char  First char or two-char combination.
"   a:char2 Second char (optional).
"* RETURN VALUES:
"   Digraph or fallback; i.e. exactly what would be returned by typing CTRL-K +
"   a:char + a:char2
"******************************************************************************
    let s:digraph = ''
    execute 'silent normal!' ":\<C-k>" . a:char . join(a:000, '') . "\<C-\>eextend(s:, {'digraph': getcmdline()}).digraph\n"
    return s:digraph
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
