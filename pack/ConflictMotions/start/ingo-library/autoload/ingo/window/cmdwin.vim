" ingo/window/cmdwin.vim: Functions for dealing with the command window.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.004	15-Oct-2013	Replace conditional with ingo#list#Make().
"   1.011.003	23-Jul-2013	Change naming of augroup to match ingo-library
"				convention.
"   1.010.002	08-Jul-2013	Add prefix to exception thrown from
"				ingo#window#cmdwin#UndefineMappingForCmdwin().
"   1.004.001	08-Apr-2013	file creation from autoload/ingowindow.vim

" The command-line window is implemented as a window, so normal mode mappings
" apply here as well. However, certain actions cannot be performed in this
" special window. The 'CmdwinEnter' event can be used to redefine problematic
" normal mode mappings.
let s:CmdwinMappings = {}
function! ingo#window#cmdwin#UndefineMappingForCmdwin( mappings, ... )
"*******************************************************************************
"* PURPOSE:
"   Register mappings that should be undefined in the command-line window.
"   Previously registered mappings equal to a:mappings will be overwritten.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   :nnoremap <buffer> the a:mapping
"* INPUTS:
"   a:mapping	    Mapping (or list of mappings) to be undefined.
"   a:alternative   Optional mapping to be used instead. If omitted, the
"		    a:mapping is undefined (i.e. mapped to itself). If empty,
"		    a:mapping is mapped to <Nop>.
"* RETURN VALUES:
"   1 if accepted; 0 if autocmds not available
"*******************************************************************************
    let l:alternative = (a:0 > 0 ? (empty(a:1) ? '<Nop>' : a:1) : '')

    for l:mapping in ingo#list#Make(a:mappings)
	let s:CmdwinMappings[l:mapping] = l:alternative
    endfor
    return has('autocmd')
endfunction
function! s:UndefineMappings()
    for l:mapping in keys(s:CmdwinMappings)
	let l:alternative = s:CmdwinMappings[ l:mapping ]
	execute 'nnoremap <buffer> ' . l:mapping . ' ' . (empty(l:alternative) ? l:mapping : l:alternative)
    endfor
endfunction
if has('autocmd')
    augroup IngoLibraryCmdWin
	autocmd! CmdwinEnter * call <SID>UndefineMappings()
    augroup END
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
