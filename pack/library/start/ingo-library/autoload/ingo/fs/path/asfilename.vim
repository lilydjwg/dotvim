" ingo/fs/path/asfilename.vim: Encode / decode any filespec as a single filename.
"
" DEPENDENCIES:
"   - ingo/dict.vim autoload script
"   - ingo/fs/path.vim autoload script
"   - ingo/fs/path/split.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	18-Oct-2016	file creation
let s:save_cpo = &cpo
set cpo&vim

    " ex_docmd.c:11754
    " We want a file name without separators, because we're not going to make
    " a directory.
    " "normal" path separator	-> "=+"
    " "="			-> "=="
    " ":" path separator	-> "=-"
let s:encoder = {
\   ingo#fs#path#Separator(): '=+',
\   '=': '==',
\   ':': '=-',
\}
let s:decoder = ingo#dict#Mirror(s:encoder)

function! ingo#fs#path#asfilename#Encode( filespec )
"******************************************************************************
"* PURPOSE:
"   Encode a:filespec as a single filename, like :mkview does.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  file spec (existing or non-existing, expansion to absolute path
"		and normalization will be attempted)
"* RETURN VALUES:
"   file name representing the absolute a:filespec; any path separators are
"   escaped.
"******************************************************************************
    let l:filespec = ingo#fs#path#Normalize(fnamemodify(a:filespec, ':p'))
    if ! empty($HOME)
	let l:homeRelativeFilespec = ingo#fs#path#split#AtBasePath(l:filespec, $HOME)
	if type(l:homeRelativeFilespec) != type([])
	    let l:filespec = ingo#fs#path#Combine('~', l:homeRelativeFilespec)
	endif
    endif

    return substitute(l:filespec, '[=' . escape(ingo#fs#path#Separator(), '\') . (ingo#os#IsWinOrDos() ? ':' : '') . ']', '\=s:encoder[submatch(0)]', 'g')
endfunction
function! ingo#fs#path#asfilename#Decode( filename )
"******************************************************************************
"* PURPOSE:
"   Decode a filespec encoded in a single filename via
"   ingo#fs#path#asfilename#Encode() to a filespec.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filename  Encoded filespec
"* RETURN VALUES:
"   filespec
"******************************************************************************
    return expand(substitute(a:filename, '=[+=-]', '\=s:decoder[submatch(0)]', 'g'))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
