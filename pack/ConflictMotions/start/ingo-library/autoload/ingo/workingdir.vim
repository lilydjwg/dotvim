" ingo/workingdir.vim: Functions to deal with the current working directory.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:compatFor = (exists('g:IngoLibrary_CompatFor') ? ingo#collections#ToDict(split(g:IngoLibrary_CompatFor, ',')) : {})

if exists('*haslocaldir') && ! has_key(s:compatFor, 'haslocaldir')
    function! ingo#workingdir#ChdirCommand()
	return (haslocaldir() ? 'lchdir!' : 'chdir!')
    endfunction
else
    function! ingo#workingdir#ChdirCommand()
	return 'chdir!'
    endfunction
endif

function! ingo#workingdir#Chdir( dirspec )
    execute ingo#workingdir#ChdirCommand() ingo#compat#fnameescape(a:dirspec)
endfunction
function! ingo#workingdir#ChdirToSpecial( cmdlineSpecial )
    execute ingo#workingdir#ChdirCommand() a:cmdlineSpecial
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
