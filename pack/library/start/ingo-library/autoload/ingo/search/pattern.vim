" ingo/search/pattern.vim: Functions for the search pattern.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.002	11-Sep-2013	Minor: Return last search pattern instead of
"				empty string on
"				ingo#search#pattern#GetLastForwardSearch(0).
"   1.006.001	24-May-2013	file creation

function! ingo#search#pattern#GetLastForwardSearch( ... )
"******************************************************************************
"* PURPOSE:
"   Get @/, or the a:count'th last search pattern, but also handle the case
"   where the pattern was set from a backward search, and doesn't have "/"
"   characters properly escaped.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:count Optional index into the end of the search history. 0 returns the
"   last search pattern, 1 the last from the history. (Usually, those should be
"   equal).
"* RETURN VALUES:
"   Last search pattern ready to use in a :s/{pat}/ command, with forward
"   slashes properly escaped.
"******************************************************************************
    return substitute((a:0 && a:1 ? histget('search', -1 * a:1) : @/), '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!/', '\\/', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
