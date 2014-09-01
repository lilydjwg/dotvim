" ingo/regexp/previoussubstitution.vim: Function to get the previous substitution |s~|
"
" DEPENDENCIES:
"   - ingo/buffer/temp.vim autoload script
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.012.005	08-Aug-2013	Move escapings.vim into ingo-library.
"   1.009.004	14-Jun-2013	Minor: Make matchstr() robust against
"				'ignorecase'.
"   1.008.003	12-Jun-2013	Change implementation from doing a :substitute
"				in a temp buffer (which has the nasty side
"				effect of clobbering the remembered flags) to
"				writing a temporary viminfo file and parsing
"				that.
"   1.008.002	11-Jun-2013	Use :s_& flag to avoid clobbering the remembered
"				flags. (Important for SmartCase.vim.)
"				Avoid clobbering the search history.
"	001	11-Jun-2013	file creation from ingomappings.vim

function! ingo#regexp#previoussubstitution#Get()
    " The substitution string is not exposed via a Vim variable, nor does
    " substitute() recognize it.
    let l:previousSubstitution = ''

    " We would have to perform a substitution in a scratch buffer to obtain it,
    " but that unfortunately clobbers the remembered flags, something that can
    " be important around custom substitutions. (Can't use the :s_& flag,
    " neither, since using :s_c would block the substitution with a query.)
    " It also doesn't allow us to retrieve |sub-replace-special| expressions,
    " just the (first) actual replacement result.
    "
    " Therefore, a better yet even more involved workaround is to extract the
    " value from a temporary |viminfo| file.
    let l:tempfile = tempname()
    let l:save_viminfo = &viminfo
    set viminfo='0,/1,:0,<0,@0,s0
    try
	execute 'wviminfo!' ingo#compat#fnameescape(l:tempfile)
	let l:viminfo = join(readfile(l:tempfile), "\n")
	let l:previousSubstitution = matchstr(l:viminfo, '\C\n# Last Substitute String:\n\$\zs\_.\{-}\ze\n\n# .* (newest to oldest):\n')
    catch /^Vim\%((\a\+)\)\=:/
	" Fallback.
	let l:previousSubstitution = ingo#buffer#temp#Execute('substitute/^/' . (&magic ? '~' : '\~') . '/')
	call histdel('search', -1)
    finally
	let &viminfo = l:save_viminfo
	call delete(l:tempfile)
    endtry

    return l:previousSubstitution
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
