" ingo/fs/path/split.vim: Functions for splitting a file system path.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.001	22-May-2014	file creation

function! ingo#fs#path#split#AtBasePath( filespec, basePath )
    let l:filespec = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:filespec, '/'), '')
    let l:basePath = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:basePath, '/'), '')
    if ingo#str#StartsWith(l:filespec, l:basePath, ingo#fs#path#IsCaseInsensitive(l:filespec))
	return strpart(a:filespec, len(l:basePath))
    endif
    return []
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
