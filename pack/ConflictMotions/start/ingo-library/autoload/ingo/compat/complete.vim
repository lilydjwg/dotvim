" ingo/compat/complete.vim: Function to retrofit :command -complete=filetype.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.022.002	22-Sep-2014	Use ingo#compat#globpath().
"   1.007.001	05-Jun-2013	file creation from ingocommands.vim

function! s:GenerateRuntimeFiletypes()
    let l:runtimeFiletypes = []

    " Vim filetypes can be gathered from the directory trees in 'runtimepath';
    " there are different kinds of filetype-specific plugins.
    " Extensions for a filetype "xxx" are specified either via "xxx_suffix.vim"
    " or a "xxx/*.vim" subdirectory. The latter isn't contained in the glob, the
    " first is explicitly filtered out.
    for l:kind in ['ftplugin', 'indent', 'syntax']
	call extend(l:runtimeFiletypes,
	\	filter(
	\	    map(
	\		ingo#compat#globpath(&runtimepath, l:kind . '/*.vim', 0, 1),
	\		'fnamemodify(v:val, ":t:r")'
	\	    ),
	\	    'v:val !~# "_"'
	\	)
	\)
    endfor

    function! s:IsUnique( val )
	let l:isUnique = (! exists('s:prevVal') || a:val !=# s:prevVal)
	let s:prevVal = a:val
	return l:isUnique
    endfunction
    let l:runtimeFiletypes = filter(
    \   sort(l:runtimeFiletypes),
    \   's:IsUnique(v:val)'
    \)
    delfunction s:IsUnique

    return l:runtimeFiletypes
endfunction
"******************************************************************************
"* PURPOSE:
"   Provide :command -complete=filetype for older Vim versions that don't support it.
"   Use like this:
"   try
"	command -complete=filetype ...
"   catch /^Vim\%((\a\+)\)\=:E180:/ " E180: Invalid complete value
"	command -complete=customlist,ingo#compat#complete#FileType ...
"   endtry
    call ingo#msg#VimExceptionMsg()
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES:
"	? Explanation of the value returned.
"******************************************************************************
function! ingo#compat#complete#FileType( ArgLead, CmdLine, CursorPos )
    if ! exists('s:runtimeFiletypes')
	let s:runtimeFiletypes = s:GenerateRuntimeFiletypes()
    endif

    let l:filetypes = filter(copy(s:runtimeFiletypes), 'v:val =~ ''\V\^'' . escape(a:ArgLead, "\\")')
    return sort(l:filetypes)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
