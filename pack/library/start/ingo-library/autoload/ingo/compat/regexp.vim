" ingo/compat/regexp.vim: Functions for regular expression compatibility.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.001	20-Feb-2015	file creation

if exists('+regexpengine') " {{{2
    " XXX: The new NFA-based regexp engine has a problem with non-greedy \s\{-}
    " match together with the branches where only one is anchored; cp.
    " http://article.gmane.org/gmane.editors.vim.devel/43712
    " XXX: The new NFA-based regexp engine has a problem with the /\@<= pattern
    " in combination with a back reference \1; cp.
    " http://article.gmane.org/gmane.editors.vim.devel/46596
    function! ingo#compat#regexp#GetOldEnginePrefix()
	return '\%#=1'
    endfunction
else
    function! ingo#compat#regexp#GetOldEnginePrefix()
	return ''
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
