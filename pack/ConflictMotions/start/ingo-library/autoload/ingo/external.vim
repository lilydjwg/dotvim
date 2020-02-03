" ingo/external.vim: Functions to launch an external Vim instance.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.013.005	13-Sep-2013	Use operating system detection functions from
"				ingo/os.vim.
"   1.012.004	08-Aug-2013	Move escapings.vim into ingo-library.
"   1.004.003	09-Apr-2013	FIX: "E117: Unknown function: s:externalLaunch".
"   1.002.002	25-Feb-2013	ENH: Allow to specify filespec of GVIM
"				executable.
"   1.000.001	28-Jan-2013	file creation from DropQuery.vim

let s:externalLaunch = (ingo#os#IsWindows() ? 'silent !start' : 'silent !')
function! ingo#external#LaunchGvim( commands, ... )
    execute s:externalLaunch . ' ' . (a:0 ? a:1 : 'gvim') join(map(a:commands, '"-c " . ingo#compat#shellescape(v:val, 1)'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
